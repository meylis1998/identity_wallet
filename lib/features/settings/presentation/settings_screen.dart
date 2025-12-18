import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/di/service_locator.dart';
import '../../credentials/data/credential_repository.dart';
import '../../credentials/presentation/bloc/credential_bloc.dart';
import '../../credentials/presentation/bloc/credential_event.dart';
import '../../did/presentation/bloc/identity_bloc.dart';
import '../../did/presentation/bloc/identity_event.dart';
import '../../did/presentation/bloc/identity_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsEnabled = false;
  bool _isLoadingBiometrics = true;
  bool _biometricsAvailable = false;
  String _biometricTypeName = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = sl<SecureStorageService>();
    final biometricService = sl<BiometricService>();

    final enabled = await storage.getBiometricsEnabled();
    final available = await biometricService.isAvailable();
    final typeName = await biometricService.getBiometricTypeName();

    setState(() {
      _biometricsEnabled = enabled;
      _biometricsAvailable = available;
      _biometricTypeName = typeName;
      _isLoadingBiometrics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'SECURITY'),
          _SettingsTile(
            icon: Icons.fingerprint,
            title: 'Use $_biometricTypeName',
            subtitle: 'Require authentication to view credentials',
            trailing: _biometricsAvailable
                ? _isLoadingBiometrics
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _biometricsEnabled,
                        onChanged: _toggleBiometrics,
                        activeColor: AppTheme.primaryBlue,
                      )
                : const Text(
                    'Not Available',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'App Lock',
            subtitle: 'Lock wallet after inactivity',
            trailing: const Text(
              '5 minutes',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            onTap: () => _showLockTimeoutPicker(context),
          ),

          const _SectionHeader(title: 'IDENTITY'),
          BlocBuilder<IdentityBloc, IdentityState>(
            builder: (context, state) {
              String subtitle = 'Loading...';
              if (state is IdentityLoaded) {
                subtitle = state.identity?.didDocument.shortId ?? 'Not created';
              } else if (state is IdentityError) {
                subtitle = 'Error';
              }
              return _SettingsTile(
                icon: Icons.person_outline,
                title: 'My DID',
                subtitle: subtitle,
                onTap: () => context.push('/did'),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: 'Backup Identity',
            subtitle: 'Export your keys securely',
            onTap: () => _showBackupInfo(context),
          ),

          const _SectionHeader(title: 'DATA'),
          _SettingsTile(
            icon: Icons.download_outlined,
            title: 'Export Credentials',
            subtitle: 'Download all credentials as JSON',
            onTap: () => _exportCredentials(context),
          ),
          _SettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Sync Status',
            subtitle: 'Local only - no cloud sync',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Private',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const _SectionHeader(title: 'DEMO'),
          _SettingsTile(
            icon: Icons.science_outlined,
            title: 'Generate Sample Credentials',
            subtitle: 'Add demo credentials for testing',
            onTap: () => _generateSampleCredentials(context),
          ),
          _SettingsTile(
            icon: Icons.restart_alt,
            title: 'Reset Demo Data',
            subtitle: 'Clear all credentials and identity',
            isDestructive: true,
            onTap: () => _showResetConfirmation(context),
          ),

          const _SectionHeader(title: 'ABOUT'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Identity Wallet',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Licenses',
            subtitle: 'Open source licenses',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Identity Wallet',
              applicationVersion: '1.0.0',
            ),
          ),

          const SizedBox(height: AppTheme.spacing2xl),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                const Text(
                  'Identity Wallet Demo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Built with Flutter for SpruceID',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 14, color: AppTheme.accentGreen),
                    const SizedBox(width: 4),
                    const Text(
                      'Privacy-Preserving',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.verified, size: 14, color: AppTheme.primaryBlue),
                    const SizedBox(width: 4),
                    const Text(
                      'W3C Standards',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }

  Future<void> _toggleBiometrics(bool value) async {
    final storage = sl<SecureStorageService>();

    if (value) {
      final biometricService = sl<BiometricService>();
      final result = await biometricService.authenticate(
        reason: 'Authenticate to enable biometric protection',
      );

      if (result.success) {
        await storage.setBiometricsEnabled(true);
        setState(() => _biometricsEnabled = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Authentication failed'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } else {
      await storage.setBiometricsEnabled(false);
      setState(() => _biometricsEnabled = false);
    }
  }

  void _showLockTimeoutPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auto-Lock Timeout',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...[
              'Immediately',
              '1 minute',
              '5 minutes',
              '15 minutes',
              '30 minutes',
            ].map((option) => ListTile(
              title: Text(option),
              trailing: option == '5 minutes'
                  ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                  : null,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lock timeout set to $option (demo)')),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showBackupInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Identity'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'In a production wallet, you would be able to:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('• Export encrypted backup file'),
            Text('• Save recovery phrase'),
            Text('• Sync to secure cloud storage'),
            SizedBox(height: 12),
            Text(
              'This demo stores data locally in the device secure enclave.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCredentials(BuildContext context) async {
    final credentials = await sl<CredentialRepository>().getCredentials();

    if (credentials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No credentials to export')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported ${credentials.length} credentials (demo)')),
    );
  }

  Future<void> _generateSampleCredentials(BuildContext context) async {
    final identityState = context.read<IdentityBloc>().state;

    if (identityState is IdentityLoaded) {
      if (identityState.identity == null) {
        context.read<IdentityBloc>().add(const CreateIdentity(displayName: 'Demo User'));
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final updatedState = context.read<IdentityBloc>().state;
      if (updatedState is IdentityLoaded && updatedState.identity != null) {
        context.read<CredentialBloc>().add(
          GenerateSampleCredentials(updatedState.identity!.did),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sample credentials generated!')),
          );
        }
      }
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all credentials and your identity. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _resetAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData() async {
    final storage = sl<SecureStorageService>();
    await storage.deleteAll();

    if (mounted) {
      context.read<CredentialBloc>().add(const LoadCredentials());
      context.read<IdentityBloc>().add(const LoadIdentity());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset')),
      );
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wallet,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Identity Wallet'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A privacy-preserving digital identity wallet demonstration.',
              style: TextStyle(height: 1.4),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• W3C Verifiable Credentials'),
            Text('• Decentralized Identifiers (DIDs)'),
            Text('• Selective Disclosure'),
            Text('• Biometric Authentication'),
            Text('• Secure Storage'),
            Text('• WCAG Accessibility'),
            SizedBox(height: 16),
            Text(
              'Built with Flutter for SpruceID Mobile Engineer demonstration.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingLg,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorRed : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppTheme.errorRed : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textMuted,
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
