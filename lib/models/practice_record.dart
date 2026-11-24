import 'target_note.dart';

class PracticeRecord {
  PracticeRecord({required this.id, required this.startedAt, required this.completedAt,
    required this.activeMs, required this.targetMidi, required this.validMs,
    required this.inTuneMs, this.audioPath, this.toleranceCents = 50})
      : assert(activeMs >= 60000 && activeMs <= 600000),
        assert(validMs >= 0 && validMs <= activeMs),
        assert(inTuneMs >= 0 && inTuneMs <= validMs);

  Map<String, Object?> toJson() => {
    'id': id, 'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(), 'activeMs': activeMs,
    'targetMidi': targetMidi, 'validMs': validMs, 'inTuneMs': inTuneMs,
    'audioPath': audioPath, 'toleranceCents': toleranceCents,
  };

  factory PracticeRecord.fromJson(Map<String, dynamic> json) {
    final active = json['activeMs'] as int;
    final valid = json['validMs'] as int;
    final inTune = json['inTuneMs'] as int;
    if (active < 60000 || active > 600000 || valid < 0 || valid > active || inTune < 0 || inTune > valid) {
      throw const FormatException('Invalid practice duration');
    }
    return PracticeRecord(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      activeMs: active, targetMidi: json['targetMidi'] as int,
      validMs: valid, inTuneMs: inTune,
      audioPath: json['audioPath'] as String?,
      toleranceCents: json['toleranceCents'] as int,
    );
  }

  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int activeMs;
  final int targetMidi;
  final int validMs;
  final int inTuneMs;
  final String? audioPath;
  final int toleranceCents;
  DateTime get recordDate => DateTime(startedAt.year, startedAt.month, startedAt.day);
  double? get rate => validMs < 10000 ? null : inTuneMs / validMs * 100;
  String get targetLabel => TargetNote(targetMidi).label;
  String get rateLabel => rate == null ? '측정 시간 부족' : '${rate!.toStringAsFixed(1)}%';
  String get timeLabel => '${startedAt.hour.toString().padLeft(2, '0')}:${startedAt.minute.toString().padLeft(2, '0')}';
}

String formatPracticeTime(int milliseconds) {
  final seconds = milliseconds ~/ 1000;
  return '${seconds ~/ 60}분 ${seconds % 60}초';
}

List<PracticeRecord> recordsOn(List<PracticeRecord> records, DateTime day) =>
    records.where((r) => r.recordDate == DateTime(day.year, day.month, day.day)).toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

int totalActiveMs(Iterable<PracticeRecord> records) =>
    records.fold(0, (sum, record) => sum + record.activeMs);
