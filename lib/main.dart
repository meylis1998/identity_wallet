import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/services/secure_storage_service.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/credentials/presentation/wallet_screen.dart';
import 'features/credentials/presentation/credential_detail_screen.dart';
import 'features/credentials/presentation/selective_disclosure_screen.dart';
import 'features/credentials/domain/credential_model.dart';
import 'features/credentials/presentation/bloc/credential_bloc.dart';
import 'features/credentials/presentation/bloc/credential_event.dart';
import 'features/verification/presentation/qr_scanner_screen.dart';
import 'features/did/presentation/did_screen.dart';
import 'features/did/presentation/bloc/identity_bloc.dart';
import 'features/did/presentation/bloc/identity_event.dart';
import 'features/settings/presentation/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServiceLocator();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const IdentityWalletApp());
}

class IdentityWalletApp extends StatelessWidget {
  const IdentityWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CredentialBloc>(
          create: (_) => sl<CredentialBloc>()..add(const LoadCredentials()),
        ),
        BlocProvider<IdentityBloc>(
          create: (_) => sl<IdentityBloc>()..add(const LoadIdentity()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Identity Wallet',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    if (state.matchedLocation == '/') {
      final storage = sl<SecureStorageService>();
      final onboardingComplete = await storage.getOnboardingComplete();

      if (onboardingComplete) {
        return '/wallet';
      } else {
        return '/onboarding';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const _SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/credential/:id',
      builder: (context, state) {
        final credential = state.extra as VerifiableCredential?;
        return CredentialDetailScreen(
          credentialId: state.pathParameters['id']!,
          credential: credential,
        );
      },
    ),
    GoRoute(
      path: '/credential/:id/selective-disclosure',
      builder: (context, state) {
        final credential = state.extra as VerifiableCredential;
        return SelectiveDisclosureScreen(credential: credential);
      },
    ),
    GoRoute(
      path: '/scan',
      builder: (context, state) => const QRScannerScreen(),
    ),
    GoRoute(
      path: '/did',
      builder: (context, state) => const DIDScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.wallet,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            const Text(
              'Identity Wallet',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
