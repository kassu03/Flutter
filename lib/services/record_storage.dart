import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_record.dart';

class RecordStorage {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'vocalytics.records.v1';

  Future<List<PracticeRecord>> load() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => PracticeRecord.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Called when a real practice session completes; demo data never enters here.
  Future<void> save(PracticeRecord record) async {
    if (record.id.startsWith('demo-')) {
      throw ArgumentError('Demo records must not be persisted');
    }
    final records = await load();
    records.removeWhere((existing) => existing.id == record.id);
    records.add(record);
    await _preferences.setString(_key, jsonEncode(records.map((r) => r.toJson()).toList()));
  }
}
