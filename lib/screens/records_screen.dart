import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../widgets/practice_calendar.dart';
import '../widgets/practice_record_tile.dart';
import '../widgets/record_bar_chart.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key, required this.records, required this.selectedDate, required this.onDateSelected});
  final List<PracticeRecord> records;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final daily = recordsOn(records, selectedDate);
    final dateLabel = '${selectedDate.month}월 ${selectedDate.day}일';
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)));
    return ColoredBox(color: const Color(0xFFF7F9F8), child: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('연습 기록', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _RecordCard(child: Column(children: [
          PracticeCalendar(selectedDate: selectedDate, onSelected: onDateSelected, recordedDates: records.map((r) => r.recordDate).toSet()),
          TextButton(onPressed: () => onDateSelected(DateUtils.dateOnly(DateTime.now())), child: const Text('오늘로 이동')),
        ])),
        heading(dateLabel),
        _RecordCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('앱 활성 연습 시간', style: TextStyle(fontSize: 12, color: Color(0xFF66736E))),
          const SizedBox(height: 8),
          Text(formatPracticeTime(totalActiveMs(daily)), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF203A34))),
          const SizedBox(height: 8),
          Text('완료한 연습 ${daily.length}회'),
        ])),
        if (daily.isNotEmpty) ...[
        Row(children: [
          Expanded(child: heading('회차별 유지율')),
          IconButton(tooltip: '유지율 설명', icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(
              title: const Text('목표 음 유지율'),
              content: const Text('음높이가 측정된 시간 중 당시 선택한 목표 범위 안에 머문 비율입니다. 측정 가능 시간이 10초 미만이면 유지율을 표시하지 않습니다.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인'))],
            ))),
        ]),
        _RecordCard(child: daily.isEmpty
          ? const Text('이 날짜에 표시할 유지율이 없어요.')
          : RecordBarChart(labels: daily.map((r) => r.timeLabel).toList(),
              values: daily.map((r) => r.rate).toList(), maximum: 100, unit: '%')),
        ],
        heading('회차별 기록'),
        Text('총 ${daily.length}회 · ${formatPracticeTime(totalActiveMs(daily))}'),
        const SizedBox(height: 12),
        if (daily.isEmpty) const _RecordCard(child: Text('선택한 날짜의 기록이 없어요')),
        if (daily.isNotEmpty)
          LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
            key: ValueKey(selectedDate),
            scrollDirection: Axis.horizontal,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < daily.length; i++)
                Padding(
                  padding: EdgeInsets.only(right: i == daily.length - 1 ? 0 : 1),
                  child: SizedBox(
                    width: daily.length == 1 ? constraints.maxWidth : constraints.maxWidth * 0.9,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text('${i + 1}회차', style: const TextStyle(fontSize: 12, color: Color(0xFF66736E)))),
                      PracticeRecordTile(record: daily[i]),
                    ]),
                  ),
                ),
            ]),
          )),
        if (daily.length > 1)
          const Center(child: Text('좌우로 넘겨 보기', style: TextStyle(fontSize: 12, color: Color(0xFF66736E)))),
        const SizedBox(height: 16),
        const Text('기록은 현재 기기에 보관해요.', style: TextStyle(fontSize: 12, color: Color(0xFF586761))),
      ]),
    )));
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
