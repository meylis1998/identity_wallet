import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/did_model.dart';

class DIDRepository {
  final SecureStorageService _storage;

  DIDRepository(this._storage);

  Future<UserIdentity?> getUserIdentity() async {
    final json = await _storage.getDIDDocument();
    if (json == null) return null;
    return UserIdentity.fromJson(json);
  }

  Future<UserIdentity> createDID({String? displayName}) async {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final keyHash = sha256.convert(keyBytes);

    final multibaseKey = 'z${base64Url.encode(keyHash.bytes).replaceAll('=', '')}';
    final did = 'did:key:$multibaseKey';

    final didDocument = DIDDocument(
      context: [DIDContexts.didV1, DIDContexts.securitySuitesJws2020],
      id: did,
      verificationMethod: [
        VerificationMethod(
          id: '$did#keys-1',
          type: 'Ed25519VerificationKey2020',
          controller: did,
          publicKeyMultibase: multibaseKey,
        ),
      ],
      authentication: ['$did#keys-1'],
      assertionMethod: ['$did#keys-1'],
      keyAgreement: ['$did#keys-1'],
      createdAt: DateTime.now(),
    );

    final identity = UserIdentity(
      didDocument: didDocument,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await saveUserIdentity(identity);
    return identity;
  }

  Future<void> saveUserIdentity(UserIdentity identity) async {
    await _storage.storeDIDDocument(identity.toJson());
  }

  Future<UserIdentity?> updateDisplayName(String displayName) async {
    final identity = await getUserIdentity();
    if (identity == null) return null;

    final updated = UserIdentity(
      didDocument: identity.didDocument.copyWith(updatedAt: DateTime.now()),
      displayName: displayName,
      profileImageUrl: identity.profileImageUrl,
      isBackedUp: identity.isBackedUp,
      createdAt: identity.createdAt,
    );

    await saveUserIdentity(updated);
    return updated;
  }

  Future<UserIdentity?> markAsBackedUp() async {
    final identity = await getUserIdentity();
    if (identity == null) return null;

    final updated = UserIdentity(
      didDocument: identity.didDocument,
      displayName: identity.displayName,
      profileImageUrl: identity.profileImageUrl,
      isBackedUp: true,
      createdAt: identity.createdAt,
    );

    await saveUserIdentity(updated);
    return updated;
  }

  Future<void> deleteIdentity() async {
    await _storage.delete(key: AppConstants.keyDidDocument);
  }

  Future<String?> exportDIDDocument() async {
    final identity = await getUserIdentity();
    if (identity == null) return null;
    return jsonEncode(identity.didDocument.toJson());
  }

  Future<DIDDocument?> resolveDID(String did) async {
    final identity = await getUserIdentity();
    if (identity != null && identity.did == did) {
      return identity.didDocument;
    }
    return null;
  }
}
