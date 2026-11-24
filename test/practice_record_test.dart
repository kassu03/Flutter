import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lytics/models/practice_record.dart';

void main() {
  test('Midnight crossing belongs to the start day, valid threshold inclusive', () {
    final record = PracticeRecord(id: 'test', startedAt: DateTime(2026, 11, 17, 23, 59),
      completedAt: DateTime(2026, 11, 18, 0, 1), activeMs: 120000,
      targetMidi: 48, validMs: 10000, inTuneMs: 0);
    expect(record.recordDate, DateTime(2026, 11, 17));
    expect(record.rate, 0);
  });
}
