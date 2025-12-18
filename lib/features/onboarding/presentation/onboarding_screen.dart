import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/di/service_locator.dart';
import '../../did/presentation/bloc/identity_bloc.dart';
import '../../did/presentation/bloc/identity_event.dart';
import '../../did/presentation/bloc/identity_state.dart';
import '../../credentials/presentation/bloc/credential_bloc.dart';
import '../../credentials/presentation/bloc/credential_event.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCreatingIdentity = false;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      icon: Icons.wallet,
      title: 'Your Digital Identity Wallet',
      description:
          'Securely store and manage your digital credentials issued by government agencies and trusted organizations.',
      color: AppTheme.primaryBlue,
    ),
    const _OnboardingPage(
      icon: Icons.verified_user,
      title: 'Verifiable Credentials',
      description:
          'Receive W3C standard credentials like driver\'s licenses, voter registration, and professional licenses.',
      color: Color(0xFF059669),
    ),
    const _OnboardingPage(
      icon: Icons.privacy_tip,
      title: 'Privacy-Preserving',
      description:
          'Choose exactly what information to share. Selective disclosure puts you in control of your data.',
      color: Color(0xFF7C3AED),
    ),
    const _OnboardingPage(
      icon: Icons.security,
      title: 'Bank-Grade Security',
      description:
          'Protected by biometric authentication and encrypted storage. Your credentials never leave your device without consent.',
      color: Color(0xFFDC2626),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: TextButton(
                  onPressed: _currentPage < _pages.length - 1
                      ? () => _pageController.animateToPage(
                            _pages.length - 1,
                            duration: AppTheme.animationNormal,
                            curve: Curves.easeInOut,
                          )
                      : null,
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Skip' : '',
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _PageContent(page: page);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: AppTheme.animationFast,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : AppTheme.borderGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  if (_currentPage < _pages.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: AppTheme.animationNormal,
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                      ),
                      child: const Text('Continue'),
                    )
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _isCreatingIdentity ? null : _createIdentity,
                          child: _isCreatingIdentity
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Get Started'),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          'By continuing, you agree to create a local identity',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createIdentity() async {
    setState(() => _isCreatingIdentity = true);

    try {
      final identityBloc = context.read<IdentityBloc>();
      final credentialBloc = context.read<CredentialBloc>();

      identityBloc.add(const CreateIdentity(displayName: 'My Identity'));

      final createdIdentity = await identityBloc.stream
          .firstWhere((state) => state is IdentityCreated || state is IdentityLoaded)
          .timeout(const Duration(seconds: 10));

      String? did;
      if (createdIdentity is IdentityCreated) {
        did = createdIdentity.identity.did;
      } else if (createdIdentity is IdentityLoaded && createdIdentity.identity != null) {
        did = createdIdentity.identity!.did;
      }

      if (did != null) {
        credentialBloc.add(GenerateSampleCredentials(did));
      }

      final biometricService = sl<BiometricService>();
      final biometricsAvailable = await biometricService.isAvailable();

      if (biometricsAvailable && mounted) {
        final shouldEnable = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => _BiometricSetupDialog(
            biometricService: biometricService,
          ),
        );

        if (shouldEnable == true) {
          final storage = sl<SecureStorageService>();
          await storage.setBiometricsEnabled(true);
        }
      }

      final storage = sl<SecureStorageService>();
      await storage.setOnboardingComplete(true);

      if (mounted) {
        context.go('/wallet');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating identity: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingIdentity = false);
      }
    }
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _PageContent extends StatelessWidget {
  final _OnboardingPage page;

  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXl),

          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),

          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BiometricSetupDialog extends StatefulWidget {
  final BiometricService biometricService;

  const _BiometricSetupDialog({required this.biometricService});

  @override
  State<_BiometricSetupDialog> createState() => _BiometricSetupDialogState();
}

class _BiometricSetupDialogState extends State<_BiometricSetupDialog> {
  bool _isAuthenticating = false;
  String _biometricName = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _loadBiometricName();
  }

  Future<void> _loadBiometricName() async {
    final name = await widget.biometricService.getBiometricTypeName();
    setState(() => _biometricName = name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.fingerprint,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Enable $_biometricName?')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add an extra layer of security by requiring biometric authentication to access your credentials.',
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield,
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                const Expanded(
                  child: Text(
                    'Recommended for maximum security',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: _isAuthenticating ? null : _enableBiometrics,
          child: _isAuthenticating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Enable $_biometricName'),
        ),
      ],
    );
  }

  Future<void> _enableBiometrics() async {
    setState(() => _isAuthenticating = true);

    try {
      final result = await widget.biometricService.authenticate(
        reason: 'Authenticate to enable biometric protection',
      );

      if (result.success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Authentication failed'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }
}
