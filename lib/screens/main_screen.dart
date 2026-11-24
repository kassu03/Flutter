import 'package:flutter/material.dart';

import '../models/practice_record.dart';
import '../services/demo_records.dart';
import '../services/record_storage.dart';
import 'home_screen.dart';
import 'records_screen.dart';
import 'training_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  int _targetMidi = 60;
  bool _showDemo = false;
  final List<PracticeRecord> _records = [];
  late final List<PracticeRecord> _demoRecords = createDemoRecords(DateTime.now());
  DateTime _recordDate = DateUtils.dateOnly(DateTime.now());
  List<PracticeRecord> get _visibleRecords => _showDemo ? _demoRecords : _records;

  final _storage = RecordStorage();
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() { _loading = true; _loadFailed = false; });
    try {
      final records = await _storage.load();
      if (!mounted) return;
      setState(() { _records..clear()..addAll(records); _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _loadFailed = true; });
    }
  }

  void _selectTarget(int midi) => setState(() => _targetMidi = midi);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _loading
      ? const Center(child: CircularProgressIndicator(semanticsLabel: '기록 불러오는 중'))
      : _loadFailed
        ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('기록을 불러오지 못했어요. 기존 저장 내용은 변경하지 않았어요.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadRecords, child: const Text('다시 불러오기')),
            ],
          )))
        : IndexedStack(
      index: _selectedIndex,
      children: [
        TrainingScreen(targetMidi: _targetMidi, onTargetChanged: _selectTarget),
        HomeScreen(
          records: _visibleRecords,
          isDemo: _showDemo,
          onDemoChanged: (value) => setState(() => _showDemo = value),
          onTraining: () => setState(() => _selectedIndex = 0),
          onRecords: () => setState(() => _selectedIndex = 2),
        ),
        RecordsScreen(
          records: _visibleRecords, isDemo: _showDemo,
          selectedDate: _recordDate,
          onDateSelected: (date) => setState(() => _recordDate = date),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE5EEE7),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.mic_none_rounded),
          selectedIcon: Icon(Icons.mic_rounded),
          label: '트레이닝',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: '기록',
        ),
      ],
    ),
  );
}
