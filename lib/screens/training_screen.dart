import 'practice_screen.dart';
import 'package:flutter/material.dart';

import '../models/target_note.dart';
import '../widgets/target_note_picker.dart';
import '../widgets/pitch_preview.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.targetMidi, required this.onTargetChanged});
  final int targetMidi;
  final ValueChanged<int> onTargetChanged;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final bool _busy = false;
  final bool _running = false;
  final String _status = '시작하면 실시간 연습 화면으로 이동해요.';
  Future<void> _toggle() async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PracticeScreen(targetMidi: widget.targetMidi)));
  }

  @override
  Widget build(BuildContext context) {
    final note = TargetNote(widget.targetMidi);
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('트레이닝', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('한 음에 머무르는 연습', style: TextStyle(color: Color(0xFF586761))),
          const SizedBox(height: 24),
          IgnorePointer(ignoring: _running || _busy, child: TargetNotePicker(value: widget.targetMidi, onChanged: widget.onTargetChanged)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFE5EEE7), borderRadius: BorderRadius.circular(20)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('이번 연습의 목표', style: TextStyle(color: Color(0xFF385B50))),
              const SizedBox(height: 8),
              Text(note.label, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF214E44))),
              const SizedBox(height: 8),
              Text('${note.frequency.toStringAsFixed(2)} Hz · 허용 범위 ±50센트'),
            ]),
          ),
          const SizedBox(height: 24),
          Text('내 목소리의 음높이', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          PitchPreview(targetLabel: note.label),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Column(children: [
              Text('앱 활성 연습 시간', style: TextStyle(color: Color(0xFF586761))),
              SizedBox(height: 8),
              Text('00:00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('시간 측정은 다음 단계에서 연결해요.', style: TextStyle(fontSize: 12, color: Color(0xFF586761))),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _busy ? null : _toggle,
            icon: const Icon(Icons.mic_rounded),
            label: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text(_busy ? '연결 처리 중…' : _running ? '마이크 입력 종료' : '연습 시작')),
          )),
          const SizedBox(height: 8),
          Text(_status, style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF586761))),
          const SizedBox(height: 24),
          Text('이렇게 연습해요', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('1. 편하게 낼 수 있는 목표 음을 골라요.\n2. 내 음높이를 보며 목표 범위에 맞춰요.\n3. 1분 이상 연습하면 완료할 수 있어요.', style: TextStyle(height: 1.9)),
          const SizedBox(height: 12),
          const Text('현재는 마이크 입력 확인 단계예요. 음높이 분석·시간 측정·파일 저장은 아직 연결 전이에요. 앱을 벗어나면 마이크 입력을 종료해요.', style: TextStyle(fontSize: 12, height: 1.7, color: Color(0xFF586761))),
        ]),
      ),
    );
  }
}
