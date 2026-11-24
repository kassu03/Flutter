import 'package:flutter/material.dart';
import '../models/practice_record.dart';
import '../widgets/practice_record_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onTraining, required this.onRecords, required this.records, required this.isDemo, required this.onDemoChanged});
  final List<PracticeRecord> records;
  final bool isDemo;
  final ValueChanged<bool> onDemoChanged;
  final VoidCallback onTraining;
  final VoidCallback onRecords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = recordsOn(records, DateTime.now());
    final sorted = [...records]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary, size: 30),
            const SizedBox(width: 10),
            Text('VocaLytics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('예시 기록 보기'),
            subtitle: Text(isDemo ? '개발용 예시 · 실제 연습이 아니며 저장되지 않아요.' : '기록 화면을 예시 데이터로 확인할 수 있어요.'),
            value: isDemo, onChanged: onDemoChanged,
          ),
          const SizedBox(height: 32),
          Text('오늘도, 나의 음을 찾아서', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('작은 연습을 쌓아 나의 목소리를 알아가요.', style: TextStyle(height: 1.6, color: Color(0xFF586761))),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFE5EEE7), borderRadius: BorderRadius.circular(24)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('오늘의 연습', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF214E44))),
              const SizedBox(height: 20),
              Wrap(spacing: 32, runSpacing: 20, children: [
                _Summary(label: '앱 활성 연습 시간', value: formatPracticeTime(totalActiveMs(today))),
                _Summary(label: '완료한 연습', value: '${today.length}회'),
              ]),
              const SizedBox(height: 20),
              Text(isDemo ? '예시 기록으로 계산한 오늘의 현황이에요.' : '현재 완료한 실제 연습이 없어요.', style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF586761))),
            ]),
          ),
          const SizedBox(height: 24),
          Text(records.isEmpty ? '첫 연습을 시작해 보세요' : '다음 연습을 준비해 보세요', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('트레이닝에서 옥타브와 목표 음을 고를 수 있어요.', style: TextStyle(height: 1.6, color: Color(0xFF586761))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: onTraining,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('연습하러 가기')),
          )),
          const SizedBox(height: 8),
          const Text('현재는 목표 음 선택까지 가능해요. 마이크 연결은 준비 중이에요.', style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF586761))),
          const SizedBox(height: 28),
          Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, spacing: 24, children: [
            Text('최근 연습', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: onRecords, child: const Text('전체 기록 보기')),
          ]),
          const SizedBox(height: 8),
          if (sorted.isNotEmpty) PracticeRecordTile(record: sorted.first) else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E6DF))),
            child: const Column(children: [
              Icon(Icons.history_rounded, size: 32, color: Color(0xFF6A7D71)),
              SizedBox(height: 12),
              Text('표시할 최근 연습이 없어요', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('저장 기능을 연결하면\n가장 최근에 완료한 연습을 보여드릴게요.', textAlign: TextAlign.center, style: TextStyle(height: 1.6, color: Color(0xFF586761))),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF385B50))),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF214E44))),
    ],
  );
}
