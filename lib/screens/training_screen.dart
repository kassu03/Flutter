import 'practice_screen.dart';
import '../models/practice_record.dart';
import 'package:flutter/material.dart';

import '../models/target_note.dart';
import '../widgets/target_note_picker.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.targetMidi, required this.onTargetChanged, required this.onCompleted});
  final ValueChanged<PracticeRecord> onCompleted;
  final int targetMidi;
  final ValueChanged<int> onTargetChanged;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  Future<void> _toggle() async {
    final record = await Navigator.of(context).push<PracticeRecord>(MaterialPageRoute<PracticeRecord>(builder: (_) => PracticeScreen(targetMidi: widget.targetMidi, onTargetChanged: widget.onTargetChanged)));
    if (record != null) widget.onCompleted(record);
  }

  @override
  Widget build(BuildContext context) {
    final note = TargetNote(widget.targetMidi);
    return ColoredBox(
      color: const Color(0xFFF7F9F8),
      child: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          const Text('트레이닝', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF203A34))),
          const SizedBox(height: 8),
          const Text('옥타브와 목표 음을 선택하세요.', style: TextStyle(color: Color(0xFF66736E))),
          const SizedBox(height: 28),
          TargetNotePicker(value: widget.targetMidi, onChanged: widget.onTargetChanged),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE3E9E6)),
              boxShadow: const [BoxShadow(color: Color(0x09203A34), blurRadius: 18, offset: Offset(0, 6))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('선택한 목표 음', style: TextStyle(fontSize: 13, color: Color(0xFF66736E))),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('${widget.targetMidi ~/ 12 - 3}옥타브 ${TargetNote.koreanNames[widget.targetMidi % 12]}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF203A34))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE4F2EE), borderRadius: BorderRadius.circular(10)),
                  child: Text('${TargetNote.names[widget.targetMidi % 12]}${widget.targetMidi ~/ 12 - 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF168577))),
                ),
              ]),
              const SizedBox(height: 10),
              Text('${note.frequency.toStringAsFixed(2)} Hz · 허용 범위 ±50센트', style: const TextStyle(fontSize: 13, color: Color(0xFF66736E))),
            ]),
          ),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF168577), minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _toggle,
            icon: const Icon(Icons.mic_rounded),
            label: const Text('연습 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 12),
          const Center(child: Text('20초 이상 연습하면 완료할 수 있어요.', style: TextStyle(fontSize: 12, color: Color(0xFF66736E)))),
        ]),
      )),
    );
  }
}
