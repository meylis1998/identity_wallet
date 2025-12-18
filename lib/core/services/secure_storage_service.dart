import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
            sharedPreferencesName: 'identity_wallet_secure_prefs',
            preferencesKeyPrefix: 'identity_wallet_',
          ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
            accountName: 'identity_wallet',
          ),
        );

  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  Future<void> writeJson({required String key, required Map<String, dynamic> value}) async {
    await write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readJson({required String key}) async {
    final value = await read(key: key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  Future<void> writeJsonList({required String key, required List<Map<String, dynamic>> value}) async {
    await write(key: key, value: jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>?> readJsonList({required String key}) async {
    final value = await read(key: key);
    if (value == null) return null;
    final list = jsonDecode(value) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> storeCredentials(List<Map<String, dynamic>> credentials) async {
    await writeJsonList(key: AppConstants.keyCredentials, value: credentials);
  }

  Future<List<Map<String, dynamic>>> getCredentials() async {
    return await readJsonList(key: AppConstants.keyCredentials) ?? [];
  }

  Future<void> storeDIDDocument(Map<String, dynamic> didDocument) async {
    await writeJson(key: AppConstants.keyDidDocument, value: didDocument);
  }

  Future<Map<String, dynamic>?> getDIDDocument() async {
    return await readJson(key: AppConstants.keyDidDocument);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await write(key: AppConstants.keyBiometricsEnabled, value: enabled.toString());
  }

  Future<bool> getBiometricsEnabled() async {
    final value = await read(key: AppConstants.keyBiometricsEnabled);
    return value == 'true';
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await write(key: AppConstants.keyOnboardingComplete, value: complete.toString());
  }

  Future<bool> getOnboardingComplete() async {
    final value = await read(key: AppConstants.keyOnboardingComplete);
    return value == 'true';
  }
}
