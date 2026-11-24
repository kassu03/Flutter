import 'dart:math' as math;

class TargetNote {
  const TargetNote(this.midi);
  final int midi;
  static const names = [
    'C',
    'C♯',
    'D',
    'D♯',
    'E',
    'F',
    'F♯',
    'G',
    'G♯',
    'A',
    'A♯',
    'B',
  ];
  static const koreanNames = [
    '도', '도♯', '레', '레♯', '미', '파',
    '파♯', '솔', '솔♯', '라', '라♯', '시',
  ];
  String get label =>
      midi >= 48 && midi <= 83
      ? '${midi ~/ 12 - 3}옥 ${koreanNames[midi % 12]} (${names[midi % 12]}${midi ~/ 12 - 1})'
      : '${names[midi % 12]}${midi ~/ 12 - 1} (${koreanNames[midi % 12]})';
  // Target frequencies supplied in the PRD table, ordered C3 through B5.
  static const targetFrequencies = [
    130.81, 138.59, 146.83, 155.56, 164.81, 174.61,
    185.00, 196.00, 207.65, 220.00, 233.08, 246.94,
    261.63, 277.18, 293.66, 311.13, 329.63, 349.23,
    369.99, 392.00, 415.30, 440.00, 466.16, 493.88,
    523.25, 554.37, 587.33, 622.25, 659.25, 698.46,
    739.99, 783.99, 830.61, 880.00, 932.33, 987.77,
  ];
  double get frequency => midi >= 48 && midi <= 83
      ? targetFrequencies[midi - 48]
      : 440.0 * math.pow(2, (midi - 69) / 12);
}
