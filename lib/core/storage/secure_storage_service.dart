import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _keyAiApiKey = 'ai_api_key';
  static const String _keyAiProvider = 'ai_provider';
  static const String _keyAiBaseUrl = 'ai_base_url';

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: _keyAiApiKey, value: apiKey);
  }

  Future<String?> getApiKey() async {
    return await _storage.read(key: _keyAiApiKey);
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyAiApiKey);
  }

  Future<void> saveAiProvider(String provider) async {
    await _storage.write(key: _keyAiProvider, value: provider);
  }

  Future<String?> getAiProvider() async {
    return await _storage.read(key: _keyAiProvider);
  }

  Future<void> saveCustomBaseUrl(String url) async {
    await _storage.write(key: _keyAiBaseUrl, value: url);
  }

  Future<String?> getCustomBaseUrl() async {
    return await _storage.read(key: _keyAiBaseUrl);
  }
}
