# Digital Identity Wallet

A privacy-preserving digital identity wallet demonstration built with Flutter, showcasing W3C Verifiable Credentials, Decentralized Identifiers (DIDs), and government-grade security features.

## Overview

This mobile application demonstrates key concepts in digital identity management that align with SpruceID's mission of building privacy-preserving, standards-based digital identity solutions.

### Key Features

- **W3C Verifiable Credentials** - Full implementation of credential display, storage, and presentation
- **Decentralized Identifiers (DIDs)** - did:key generation and DID Document management
- **Selective Disclosure** - Privacy-preserving credential sharing with user consent
- **Biometric Authentication** - Face ID / Touch ID integration for secure access
- **Secure Storage** - Platform-specific encrypted storage (Keychain/EncryptedSharedPreferences)
- **QR Code Scanning** - Credential issuance and verification request handling
- **WCAG Accessibility** - Government-grade accessibility compliance
- **Professional UI/UX** - Trust-inspiring design suitable for public-sector applications

## Architecture

```
lib/
├── core/
│   ├── constants/       # App-wide constants, VC contexts
│   ├── services/        # Secure storage, biometrics
│   └── theme/           # Design system, accessibility
├── features/
│   ├── auth/            # Authentication flows
│   ├── credentials/     # VC management
│   │   ├── data/        # Repository, providers
│   │   ├── domain/      # Models (VerifiableCredential, Claims)
│   │   └── presentation/ # UI screens
│   ├── did/             # DID management
│   ├── onboarding/      # First-run experience
│   ├── settings/        # App configuration
│   └── verification/    # QR scanning, verification requests
└── shared/
    └── widgets/         # Reusable UI components
```

## Technical Highlights

### Identity Standards Compliance

- **W3C Verifiable Credentials Data Model 1.1** - Proper credential structure with contexts, types, issuers, and claims
- **W3C DID Core Specification** - DID Document generation with verification methods
- **Selective Disclosure** - Privacy-preserving presentation of credential claims

### Security Implementation

```dart
// Secure Storage with platform-specific encryption
FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,  // AES-256-GCM
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
)

// Biometric authentication before credential presentation
await localAuth.authenticate(
  localizedReason: 'Authenticate to present your credential',
  options: AuthenticationOptions(biometricOnly: true),
);
```

### State Management

Uses Riverpod for reactive state management with secure async providers:

```dart
final credentialNotifierProvider = StateNotifierProvider<
    CredentialNotifier,
    AsyncValue<List<VerifiableCredential>>
>((ref) {
  final repository = ref.read(credentialRepositoryProvider);
  return CredentialNotifier(repository);
});
```

### Accessibility (WCAG 2.1 AA)

- Semantic labels for screen readers
- Minimum touch target size (48dp)
- High contrast color ratios
- Focus management for keyboard navigation

## Demo Credentials

The app generates sample credentials for demonstration:

1. **California Driver's License** - DMV-issued with selective disclosure
2. **Voter Registration** - Secretary of State credential
3. **Vaccination Record** - Department of Public Health
4. **Education Credential** - University degree verification

## Running the Application

```bash
# Install dependencies
flutter pub get

# Run on iOS Simulator
flutter run -d ios

# Run on Android Emulator
flutter run -d android

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

## Screenshots

The application features:
- Onboarding flow with identity creation
- Credential wallet with status indicators
- Detailed credential view with all claims
- Selective disclosure picker
- QR code presentation
- DID management screen
- Secure settings with biometric toggle

## Technologies Used

- **Flutter 3.x** - Cross-platform mobile development
- **Riverpod** - State management
- **go_router** - Navigation
- **flutter_secure_storage** - Encrypted storage
- **local_auth** - Biometric authentication
- **mobile_scanner** - QR code scanning
- **qr_flutter** - QR code generation
- **crypto / pointycastle** - Cryptographic operations

## Future Enhancements

- Rust FFI integration for cryptographic libraries
- ISO/IEC 18013-5 mDL support
- OpenID4VC protocol implementation
- Bluetooth Low Energy credential transfer
- Cloud backup with user-controlled encryption

## About

This demo was built to showcase mobile engineering skills relevant to SpruceID's mission of providing privacy-preserving digital identity solutions for government and enterprise partners.

Key competencies demonstrated:
- Flutter mobile development for iOS and Android
- Digital identity standards (VCs, DIDs)
- Mobile security best practices
- Accessible, government-grade UI design
- Clean architecture patterns

---

Built with Flutter for SpruceID Mobile Engineer demonstration.
# identity_wallet
