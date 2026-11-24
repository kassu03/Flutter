import '../models/practice_record.dart';

// Only used by the explicitly enabled preview; never saved as real practice.
List<PracticeRecord> createDemoRecords(DateTime today) {
  PracticeRecord record(String id, int dayOffset, int hour, int minutes, int valid, int inTune) {
    final start = DateTime(today.year, today.month, today.day + dayOffset, hour);
    return PracticeRecord(id: id, startedAt: start,
      completedAt: start.add(Duration(minutes: minutes)), activeMs: minutes * 60000,
      targetMidi: 48, validMs: valid * 1000, inTuneMs: inTune * 1000);
  }
  return [
    record('demo-1', -3, 10, 4, 120, 90),
    record('demo-2', -1, 14, 6, 200, 160),
    record('demo-3', 0, 9, 5, 120, 90),
    record('demo-4', 0, 12, 7, 180, 153),
    record('demo-5', 0, 15, 1, 9, 7),
  ];
}
