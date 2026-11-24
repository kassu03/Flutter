import 'package:flutter_test/flutter_test.dart';
import 'package:vocal_lytics/models/practice_record.dart';
import 'package:vocal_lytics/services/demo_records.dart';

void main() {
  test('Demo records aggregate by day and exclude insufficient measurement', () {
    final day = DateTime(2026, 11, 17);
    final records = recordsOn(createDemoRecords(day), day);
    expect(records.length, 3);
    expect(totalActiveMs(records), 13 * 60000);
    expect(records[0].rate, 75);
    expect(records[1].rate, 85);
    expect(records[2].rate, isNull);
    expect(recordsOn(records, DateTime(2026, 11, 18)), isEmpty);
  });
  test('Midnight crossing belongs to the start day, valid threshold inclusive', () {
    final record = PracticeRecord(id: 'test', startedAt: DateTime(2026, 11, 17, 23, 59),
      completedAt: DateTime(2026, 11, 18, 0, 1), activeMs: 120000,
      targetMidi: 48, validMs: 10000, inTuneMs: 0);
    expect(record.recordDate, DateTime(2026, 11, 17));
    expect(record.rate, 0);
  });
}
