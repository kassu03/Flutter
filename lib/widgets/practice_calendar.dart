import 'package:flutter/material.dart';

class PracticeCalendar extends StatelessWidget {
  const PracticeCalendar({super.key, required this.selectedDate, required this.onSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(selectedDate.year, selectedDate.month);
    final offset = first.weekday % 7;
    final days = DateTime(first.year, first.month + 1, 0).day;
    final cells = ((offset + days + 6) ~/ 7) * 7;
    final today = DateTime.now();
    final primary = Theme.of(context).colorScheme.primary;
    return Column(children: [
      Row(children: [
        IconButton(tooltip: '이전 달', onPressed: () => onSelected(DateTime(first.year, first.month - 1)), icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text('${first.year}년 ${first.month}월', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        IconButton(tooltip: '다음 달', onPressed: () => onSelected(DateTime(first.year, first.month + 1)), icon: const Icon(Icons.chevron_right)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        for (final day in ['일', '월', '화', '수', '목', '금', '토'])
          Expanded(child: Text(day, textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF68756D), fontSize: 12))),
      ]),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 44),
        itemCount: cells,
        itemBuilder: (context, index) {
          final day = index - offset + 1;
          if (day < 1 || day > days) return const SizedBox.shrink();
          final date = DateTime(first.year, first.month, day);
          final selected = day == selectedDate.day;
          final isToday = DateUtils.isSameDay(date, today);
          return Semantics(
            selected: selected,
            label: '${first.year}년 ${first.month}월 $day일${isToday ? ', 오늘' : ''}',
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Material(
                color: selected ? primary : Colors.transparent,
                shape: CircleBorder(side: BorderSide(color: isToday ? primary : Colors.transparent)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onSelected(date),
                  child: Center(child: Text('$day', style: TextStyle(color: selected ? Colors.white : null))),
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }
}

