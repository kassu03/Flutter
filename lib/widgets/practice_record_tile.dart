import 'package:flutter/material.dart';
import '../models/practice_record.dart';

class PracticeRecordTile extends StatelessWidget {
  const PracticeRecordTile({super.key, required this.record});
  final PracticeRecord record;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${record.startedAt.month}/${record.startedAt.day} ${record.timeLabel} · ${record.targetLabel}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('앱 활성 시간 ${formatPracticeTime(record.activeMs)}'),
        Text('유지율 ${record.rateLabel} · 측정 가능 ${record.validMs ~/ 1000}초'),
        const SizedBox(height: 8),
        const Text('녹음 없음', style: TextStyle(color: Color(0xFF586761), fontSize: 12)),
      ]),
    ),
  );
}
