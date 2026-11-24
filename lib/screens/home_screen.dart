import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../widgets/practice_record_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTraining, required this.onRecords, required this.records});
  final List<PracticeRecord> records;
  final VoidCallback onTraining;
  final VoidCallback onRecords;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = recordsOn(records, now);
    final sorted = [...records]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day - 6 + i));
    final totals = days.map((day) => totalActiveMs(recordsOn(records, day))).toList();
    final maximum = totals.fold<int>(0, (a, b) => a > b ? a : b);
    const titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF203A34));
    return ColoredBox(
      color: const Color(0xFFF7F9F8),
      child: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          const Row(children: [
            Icon(Icons.graphic_eq_rounded, color: Color(0xFF168577), size: 28),
            SizedBox(width: 8),
            Text('VocaLytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF203A34))),
          ]),
          const SizedBox(height: 8),
          Text('${now.year}년 ${now.month}월 ${now.day}일', style: const TextStyle(color: Color(0xFF66736E), fontSize: 13)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFE4F2EE), borderRadius: BorderRadius.circular(22)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('오늘 연습', style: titleStyle),
              const SizedBox(height: 20),
              const Text('앱 활성 연습 시간', style: TextStyle(fontSize: 12, color: Color(0xFF66736E))),
              const SizedBox(height: 6),
              Text(formatPracticeTime(totalActiveMs(today)), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF203A34))),
              const SizedBox(height: 12),
              Text('완료한 연습 ${today.length}회', style: const TextStyle(color: Color(0xFF425D54))),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: onTraining,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF168577), minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            icon: const Icon(Icons.mic_rounded),
            label: const Text('트레이닝 시작', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 28),
          const Text('최근 7일', style: titleStyle),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3E9E6))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('앱 활성 연습 시간', style: TextStyle(fontSize: 12, color: Color(0xFF66736E))),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < 7; i++) Expanded(child: Semantics(
                  label: '${days[i].month}월 ${days[i].day}일 ${formatPracticeTime(totals[i])}',
                  child: Column(children: [
                    SizedBox(height: 90, child: Align(alignment: Alignment.bottomCenter, child: Container(
                      width: 18,
                      height: maximum == 0 ? 3 : (totals[i] / maximum * 90).clamp(3.0, 90.0),
                      decoration: BoxDecoration(color: totals[i] == 0 ? const Color(0xFFE9EFEC) : const Color(0xFF168577), borderRadius: BorderRadius.circular(5)),
                    ))),
                    const SizedBox(height: 10),
                    Text('${days[i].day}', style: TextStyle(fontSize: 12, fontWeight: i == 6 ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF66736E))),
                  ]),
                )),
              ]),
              const SizedBox(height: 12),
              Text('${days.first.month}/${days.first.day}–${days.last.month}/${days.last.day} · 합계 ${formatPracticeTime(totals.fold<int>(0, (a, b) => a + b))}', style: const TextStyle(fontSize: 12, color: Color(0xFF66736E))),
            ]),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('최근 기록', style: titleStyle),
            TextButton(onPressed: onRecords, child: const Text('전체 보기')),
          ]),
          const SizedBox(height: 8),
          if (sorted.isEmpty)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3E9E6))),
              child: const Column(children: [
                Icon(Icons.history_rounded, color: Color(0xFF789188), size: 30),
                SizedBox(height: 12),
                Text('아직 완료한 연습이 없어요', style: TextStyle(color: Color(0xFF66736E))),
              ]),
            )
          else
            for (final record in sorted.take(3)) PracticeRecordTile(record: record),
        ]),
      )),
    );
  }
}
