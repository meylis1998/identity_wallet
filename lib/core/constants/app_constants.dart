class AppConstants {
  static const String appName = 'Identity Wallet';
  static const String appVersion = '1.0.0';
  static const String orgName = 'SpruceID Demo';

  static const String keyDidDocument = 'did_document';
  static const String keyCredentials = 'credentials';
  static const String keyBiometricsEnabled = 'biometrics_enabled';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keySelectedDisclosures = 'selected_disclosures';

  static const String didMethodKey = 'did:key';
  static const String didMethodWeb = 'did:web';
  static const String didMethodIon = 'did:ion';

  static const String credentialTypeDriversLicense = 'DriversLicenseCredential';
  static const String credentialTypeStateId = 'StateIDCredential';
  static const String credentialTypeVoterRegistration = 'VoterRegistrationCredential';
  static const String credentialTypeVaccination = 'VaccinationCredential';
  static const String credentialTypeEducation = 'EducationCredential';

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const Duration verificationTimeout = Duration(seconds: 30);
  static const int maxVerificationAttempts = 3;
}

class VCContexts {
  static const String credentialsV1 = 'https://www.w3.org/2018/credentials/v1';
  static const String credentialsV2 = 'https://www.w3.org/ns/credentials/v2';
  static const String securityV2 = 'https://w3id.org/security/v2';
}

class DIDContexts {
  static const String didV1 = 'https://www.w3.org/ns/did/v1';
  static const String securitySuitesJws2020 = 'https://w3id.org/security/suites/jws-2020/v1';
}
