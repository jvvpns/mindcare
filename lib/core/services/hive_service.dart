import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare/core/constants/app_constants.dart';

class HiveService {
  HiveService._();

  static const _encryptionKeyName = 'hive_encryption_key';
  static final _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> init() async {
    await Hive.initFlutter();
    final encryptionKey = await _getOrCreateEncryptionKey();
    await _openBoxes(encryptionKey);
  }

  static Future<List<int>> _getOrCreateEncryptionKey() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);

    if (existingKey != null) {
      return existingKey.codeUnits;
    }

    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: String.fromCharCodes(newKey),
    );
    return newKey;
  }

  static Future<void> _openBoxes(List<int> encryptionKey) async {
    final cipher = HiveAesCipher(encryptionKey);

    // Encrypted boxes — HIGH sensitivity
    await Hive.openBox(
      AppConstants.journalBoxName,
      encryptionCipher: cipher,
    );
    await Hive.openBox(
      AppConstants.chatBoxName,
      encryptionCipher: cipher,
    );

    // Unencrypted boxes — MEDIUM/LOW sensitivity
    await Hive.openBox(AppConstants.moodBoxName);
    await Hive.openBox(AppConstants.settingsBoxName);
    await Hive.openBox(AppConstants.assessmentBoxName);
  }

  static Box getBox(String boxName) => Hive.box(boxName);

  static Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }

  static Future<void> deleteAllData() async {
    for (final boxName in [
      AppConstants.moodBoxName,
      AppConstants.journalBoxName,
      AppConstants.chatBoxName,
      AppConstants.settingsBoxName,
      AppConstants.assessmentBoxName,
    ]) {
      await Hive.box(boxName).deleteFromDisk();
    }
    await _secureStorage.delete(key: _encryptionKeyName);
  }
}