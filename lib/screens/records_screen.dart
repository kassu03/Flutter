import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../widgets/practice_calendar.dart';
import '../widgets/practice_record_tile.dart';
import '../widgets/record_bar_chart.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key, required this.records, required this.isDemo, required this.selectedDate, required this.onDateSelected});
  final List<PracticeRecord> records;
  final bool isDemo;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final daily = recordsOn(records, selectedDate);
    final days = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final minutes = List.generate(days, (i) => totalActiveMs(recordsOn(records, DateTime(selectedDate.year, selectedDate.month, i + 1))) / 60000);
    final maxMinutes = minutes.fold<double>(1, (a, b) => a > b ? a : b).ceilToDouble();
    final dateLabel = '${selectedDate.month}월 ${selectedDate.day}일';
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)));
    return SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('나의 연습 기록', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(isDemo ? '예시 기록 · 실제 연습 결과가 아니에요.' : '이 브라우저에 저장된 연습 기록이에요.', style: TextStyle(color: theme.colorScheme.primary)),
        const SizedBox(height: 16),
        _RecordCard(child: Column(children: [
          PracticeCalendar(selectedDate: selectedDate, onSelected: onDateSelected),
          TextButton(onPressed: () => onDateSelected(DateUtils.dateOnly(DateTime.now())), child: const Text('오늘로 이동')),
        ])),
        heading('${selectedDate.month}월의 연습 시간'),
        _RecordCard(child: RecordBarChart(
          labels: List.generate(days, (i) => '${i + 1}일'), values: minutes,
          maximum: maxMinutes, unit: '분',
        )),
        heading('$dateLabel 목표 음 유지율'),
        _RecordCard(child: daily.isEmpty
          ? const Text('이 날짜에 표시할 유지율이 없어요.')
          : RecordBarChart(labels: List.generate(daily.length, (i) => '${i + 1}회차'),
              values: daily.map((r) => r.rate).toList(), maximum: 100, unit: '%')),
        heading('$dateLabel 연습 목록'),
        Text('총 ${daily.length}회 · ${formatPracticeTime(totalActiveMs(daily))}'),
        const SizedBox(height: 12),
        if (daily.isEmpty) const _RecordCard(child: Text('선택한 날짜에 연습 기록이 없어요.')),
        for (final record in daily) PracticeRecordTile(record: record),
        const SizedBox(height: 16),
        const Text('기록은 이 브라우저에 보관해요. 녹음 재생은 아직 연결 전이에요.', style: TextStyle(fontSize: 12, color: Color(0xFF586761))),
      ]),
    ));
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E6DF))),
    child: child,
  );
}
