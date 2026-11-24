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
        Text('${record.startedAt.month}/${record.startedAt.day} ${record.timeLabel}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('마지막 목표 음 ${record.targetLabel}', style: const TextStyle(color: Color(0xFF425D54))),
        const SizedBox(height: 8),
        Text('앱 활성 연습 시간 ${formatPracticeTime(record.activeMs)}'),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE4F2EE), borderRadius: BorderRadius.circular(8)),
            child: Text('유지율 ${record.rateLabel}', style: const TextStyle(color: Color(0xFF168577), fontWeight: FontWeight.w600))),
          Text('측정 가능 ${record.validMs ~/ 1000}초', style: const TextStyle(fontSize: 12, color: Color(0xFF66736E))),
        ]),
      ]),
    ),
  );
}
