import 'package:uuid/uuid.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/credential_model.dart';

class CredentialRepository {
  final SecureStorageService _storage;
  final Uuid _uuid = const Uuid();

  CredentialRepository(this._storage);

  Future<List<VerifiableCredential>> getCredentials() async {
    final jsonList = await _storage.getCredentials();
    return jsonList.map((json) => VerifiableCredential.fromJson(json)).toList();
  }

  Future<void> addCredential(VerifiableCredential credential) async {
    final credentials = await getCredentials();
    credentials.add(credential);
    await _storage.storeCredentials(
      credentials.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> removeCredential(String id) async {
    final credentials = await getCredentials();
    credentials.removeWhere((c) => c.id == id);
    await _storage.storeCredentials(
      credentials.map((c) => c.toJson()).toList(),
    );
  }

  Future<void> updateCredential(VerifiableCredential credential) async {
    final credentials = await getCredentials();
    final index = credentials.indexWhere((c) => c.id == credential.id);
    if (index != -1) {
      credentials[index] = credential;
      await _storage.storeCredentials(
        credentials.map((c) => c.toJson()).toList(),
      );
    }
  }

  Future<VerifiableCredential?> getCredential(String id) async {
    final credentials = await getCredentials();
    try {
      return credentials.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> generateSampleCredentials(String holderDid) async {
    final now = DateTime.now();

    final sampleCredentials = [
      VerifiableCredential(
        id: 'urn:uuid:${_uuid.v4()}',
        context: [VCContexts.credentialsV1],
        type: ['VerifiableCredential', AppConstants.credentialTypeDriversLicense],
        issuer: 'did:web:dmv.ca.gov',
        issuerName: 'California DMV',
        issuerLogoUrl: '',
        issuanceDate: now.subtract(const Duration(days: 365)),
        expirationDate: now.add(const Duration(days: 365 * 4)),
        holderDid: holderDid,
        claims: [
          const CredentialClaim(
            id: 'firstName',
            label: 'First Name',
            value: 'Alex',
            required: true,
          ),
          const CredentialClaim(
            id: 'lastName',
            label: 'Last Name',
            value: 'Johnson',
            required: true,
          ),
          const CredentialClaim(
            id: 'dateOfBirth',
            label: 'Date of Birth',
            value: '1990-05-15',
            sensitive: true,
          ),
          const CredentialClaim(
            id: 'address',
            label: 'Address',
            value: '123 Main St, Sacramento, CA 95814',
            sensitive: true,
          ),
          const CredentialClaim(
            id: 'licenseNumber',
            label: 'License Number',
            value: 'D1234567',
            required: true,
          ),
          const CredentialClaim(
            id: 'licenseClass',
            label: 'License Class',
            value: 'C',
          ),
          const CredentialClaim(
            id: 'over21',
            label: 'Over 21',
            value: 'true',
          ),
        ],
        status: CredentialStatus.valid,
        credentialType: CredentialType.driversLicense,
        addedAt: now,
      ),
      VerifiableCredential(
        id: 'urn:uuid:${_uuid.v4()}',
        context: [VCContexts.credentialsV1],
        type: ['VerifiableCredential', AppConstants.credentialTypeVoterRegistration],
        issuer: 'did:web:sos.ca.gov',
        issuerName: 'California Secretary of State',
        issuerLogoUrl: '',
        issuanceDate: now.subtract(const Duration(days: 180)),
        expirationDate: null,
        holderDid: holderDid,
        claims: [
          const CredentialClaim(
            id: 'fullName',
            label: 'Full Name',
            value: 'Alex M. Johnson',
            required: true,
          ),
          const CredentialClaim(
            id: 'registrationDate',
            label: 'Registration Date',
            value: '2020-09-15',
          ),
          const CredentialClaim(
            id: 'county',
            label: 'County',
            value: 'Sacramento',
          ),
          const CredentialClaim(
            id: 'precinct',
            label: 'Precinct',
            value: '42-A',
          ),
          const CredentialClaim(
            id: 'partyAffiliation',
            label: 'Party Affiliation',
            value: 'No Party Preference',
            sensitive: true,
          ),
        ],
        status: CredentialStatus.valid,
        credentialType: CredentialType.voterRegistration,
        addedAt: now,
      ),
      VerifiableCredential(
        id: 'urn:uuid:${_uuid.v4()}',
        context: [VCContexts.credentialsV1],
        type: ['VerifiableCredential', AppConstants.credentialTypeVaccination],
        issuer: 'did:web:cdph.ca.gov',
        issuerName: 'CA Dept. of Public Health',
        issuerLogoUrl: '',
        issuanceDate: now.subtract(const Duration(days: 90)),
        expirationDate: now.add(const Duration(days: 275)),
        holderDid: holderDid,
        claims: [
          const CredentialClaim(
            id: 'patientName',
            label: 'Patient Name',
            value: 'Alex Johnson',
            required: true,
          ),
          const CredentialClaim(
            id: 'vaccine',
            label: 'Vaccine',
            value: 'COVID-19 mRNA',
            required: true,
          ),
          const CredentialClaim(
            id: 'dose',
            label: 'Dose',
            value: 'Booster (3rd)',
          ),
          CredentialClaim(
            id: 'administrationDate',
            label: 'Administration Date',
            value: now.subtract(const Duration(days: 90)).toString().split(' ')[0],
          ),
          const CredentialClaim(
            id: 'lotNumber',
            label: 'Lot Number',
            value: 'EL9269',
            sensitive: true,
          ),
        ],
        status: CredentialStatus.valid,
        credentialType: CredentialType.vaccination,
        addedAt: now,
      ),
      VerifiableCredential(
        id: 'urn:uuid:${_uuid.v4()}',
        context: [VCContexts.credentialsV1],
        type: ['VerifiableCredential', AppConstants.credentialTypeEducation],
        issuer: 'did:web:berkeley.edu',
        issuerName: 'UC Berkeley',
        issuerLogoUrl: '',
        issuanceDate: now.subtract(const Duration(days: 730)),
        expirationDate: null,
        holderDid: holderDid,
        claims: [
          const CredentialClaim(
            id: 'studentName',
            label: 'Name',
            value: 'Alex M. Johnson',
            required: true,
          ),
          const CredentialClaim(
            id: 'degree',
            label: 'Degree',
            value: 'Bachelor of Science',
            required: true,
          ),
          const CredentialClaim(
            id: 'major',
            label: 'Major',
            value: 'Computer Science',
          ),
          const CredentialClaim(
            id: 'graduationDate',
            label: 'Graduation Date',
            value: '2020-05-15',
          ),
          const CredentialClaim(
            id: 'gpa',
            label: 'GPA',
            value: '3.85',
            sensitive: true,
          ),
          const CredentialClaim(
            id: 'studentId',
            label: 'Student ID',
            value: '3035812456',
            sensitive: true,
          ),
        ],
        status: CredentialStatus.valid,
        credentialType: CredentialType.education,
        addedAt: now,
      ),
    ];

    for (final credential in sampleCredentials) {
      await addCredential(credential);
    }
  }

  Future<void> clearAllCredentials() async {
    await _storage.storeCredentials([]);
  }
}
