import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/pitch_worker.dart';
import '../services/practice_timer.dart';
import '../models/practice_record.dart';
import '../services/record_storage.dart';
import '../widgets/target_note_picker.dart';
import '../models/target_note.dart';
import '../services/microphone_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.targetMidi, required this.onTargetChanged});
  final int targetMidi;
  final ValueChanged<int> onTargetChanged;
  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late int _targetMidi;
  final _storage = RecordStorage();
  DateTime? _startedAt;
  PracticeRecord? _pendingRecord;
  bool _completed = false;
  int _validSamples = 0, _inTuneSamples = 0;
  int _generation = 0, _analysisGeneration = 0, _analysisTarget = 60;
  Completer<void>? _analysisDone;
  final _mic = MicrophoneService();
  final _practiceTimer = PracticeTimer();
  Timer? _timeRefresh;
  bool _active = true;
  bool _acceptInput = false;

  String get _elapsedLabel {
    final seconds = _practiceTimer.elapsed.inSeconds;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  final _worker = PitchWorker();
  late final AnimationController _scroll;
  final _clock = Stopwatch();
  int _lastPointMs = 0;
  bool _workerReady = false;
  final List<int> _buffer = [];
  final List<double?> _history = [];
  bool _busy = false, _running = false, _analyzing = false;
  double? _pitch;
  String _status = '마이크 준비 중';


  @override
  void initState() { super.initState(); _targetMidi = widget.targetMidi; WidgetsBinding.instance.addObserver(this);
    _scroll = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _timeRefresh = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted && _running) setState(() {});
    });
    _clock.start();
    unawaited(_prepare()); }

  Future<void> _prepare() async {
    try {
      await _worker.start((pitch, wave) {
        _analyzing = false;
        if (_analysisGeneration == _generation && pitch != null) {
          _validSamples += 4096;
          final cents = 1200 * math.log(pitch / TargetNote(_analysisTarget).frequency) / math.ln2;
          if (cents.abs() <= 50) _inTuneSamples += 4096;
        }
        _analysisDone?.complete();
        _analysisDone = null;
        if (!mounted || !_running || _analysisGeneration != _generation || _analysisTarget != _targetMidi) return;
        setState(() {
          _pitch = pitch; _lastPointMs = _clock.elapsedMilliseconds;
          _history.add(pitch == null ? null : 1200 * math.log(pitch / TargetNote(_targetMidi).frequency) / math.ln2);
          if (_history.length > 80) _history.removeAt(0);
        });
      });
      _workerReady = true;
      if (mounted) await _start();
    } catch (_) { if (mounted) setState(() => _status = '분석 준비에 실패했어요. 화면을 다시 열어 주세요.'); }
  }

  Future<void> _start() async {
    if (_busy || !_active) return;
    setState(() { _busy = true; _status = '마이크 연결 중'; });
    _acceptInput = true;
    try {
      final allowed = await _mic.start(onInput: () {
        if (_acceptInput && _active) { _startedAt ??= DateTime.now(); _practiceTimer.start(); }
      }, onFailure: () => unawaited(_pause('입력이 중단됐어요. 다시 시도해 주세요.')), onData: _data);
      if (!_active || !_acceptInput) {
        _practiceTimer.pause();
        await _mic.stop();
        return;
      }
      if (!allowed) { _acceptInput = false; _practiceTimer.pause(); }
      if (mounted) setState(() { _running = allowed; _status = allowed ? '목표 음에 맞춰 소리를 내 보세요.' : '마이크 권한을 허용해 주세요.'; });
    } catch (_) { _acceptInput = false; _practiceTimer.pause(); if (mounted) setState(() => _status = '마이크 연결 실패 · 다시 시도해 주세요.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  void _data(Uint8List data) {
    if (!_workerReady || !_running) return;
    _buffer.addAll(data);
    if (_buffer.length < 8192) return;
    final chunk = Uint8List.fromList(_buffer.sublist(_buffer.length - 8192));
    _buffer.clear();
    if (_analyzing) return;
    _analyzing = true;
    _analysisGeneration = _generation;
    _analysisTarget = _targetMidi;
    _analysisDone = Completer<void>();
    _worker.analyze(chunk);
  }

  Future<void> _pause([String message = '일시정지 · 이어하기를 눌러 주세요.']) async {
    _acceptInput = false;
    _practiceTimer.pause();
    _generation++;
    _buffer.clear();
    try { await _mic.stop(); } catch (_) {}
    if (mounted) setState(() { _running = false; _pitch = null; _history.add(null); _status = message; });
  }

  Future<void> _complete() async {
    if (_busy || _practiceTimer.elapsed.inMilliseconds < 20000) return;
    setState(() => _busy = true);
    try {
      // Stop capture first, then include the last submitted analysis once.
      _acceptInput = false;
      _practiceTimer.pause();
      await _mic.stop();
      if (_analysisDone != null) await _analysisDone!.future;
      await _pause('연습 완료 · 저장 중');
      _completed = true;
      final now = DateTime.now();
      _pendingRecord ??= PracticeRecord(
        id: 'practice-${now.microsecondsSinceEpoch}',
        startedAt: _startedAt!, completedAt: now,
        activeMs: _practiceTimer.elapsed.inMilliseconds,
        targetMidi: _targetMidi,
        validMs: (_validSamples * 1000 ~/ 44100).clamp(0, _practiceTimer.elapsed.inMilliseconds),
        inTuneMs: (_inTuneSamples * 1000 ~/ 44100).clamp(0, (_validSamples * 1000 ~/ 44100).clamp(0, _practiceTimer.elapsed.inMilliseconds)),
      );
      await _storage.save(_pendingRecord!);
      if (mounted) Navigator.pop(context, _pendingRecord);
    } catch (_) {
      if (mounted) setState(() => _status = '저장에 실패했어요. 저장 재시도를 눌러 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _end() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('연습을 중단할까요?'), content: const Text('현재 연습은 저장되지 않아요.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('돌아가기')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('중단'))],
    ));
    if (confirmed != true) return;
    await _pause();
    if (mounted) Navigator.pop(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active && (_running || _busy)) {
      _acceptInput = false;
      _practiceTimer.pause();
      if (_running) unawaited(_pause('앱을 벗어나 일시정지했어요. 이어하기를 눌러 주세요.'));
    }
  }
  @override
  void dispose() { _acceptInput = false; _practiceTimer.pause(); _timeRefresh?.cancel(); WidgetsBinding.instance.removeObserver(this); _worker.dispose(); _scroll.dispose(); _clock.stop(); unawaited(_mic.dispose()); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final note = TargetNote(_targetMidi);
    final cents = _history.isEmpty ? null : _history.last;
    final inTune = _running && cents != null && cents.abs() <= 50;
    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (!didPop) unawaited(_end()); }, child: Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F8),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('연습 중', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: _busy ? null : _end, icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(24, 12, 24, 24), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3E9E6)), boxShadow: const [BoxShadow(color: Color(0x09203A34), blurRadius: 18, offset: Offset(0, 6))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('목표 음', style: TextStyle(color: Color(0xFF66736E), fontSize: 13)),
              TextButton(onPressed: _busy || _completed ? null : () async {
                await showModalBottomSheet<void>(
                  context: context, isScrollControlled: true,
                  builder: (sheetContext) => SafeArea(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: StatefulBuilder(builder: (context, updateSheet) => Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('목표 음 선택', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TargetNotePicker(value: _targetMidi, onChanged: (midi) {
                        setState(() { _targetMidi = midi; _history.clear(); _pitch = null; _buffer.clear(); });
                        updateSheet(() {});
                        widget.onTargetChanged(midi);
                      }),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('선택 완료')),
                    ])),
                  )),
                );
              }, child: const Text('변경')),
            ]),
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
              Text('${_targetMidi ~/ 12 - 3}옥타브 ${TargetNote.koreanNames[_targetMidi % 12]}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF203A34))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFE4F2EE), borderRadius: BorderRadius.circular(10)),
                child: Text('${TargetNote.names[_targetMidi % 12]}${_targetMidi ~/ 12 - 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF168577)))),
            ]),
            const SizedBox(height: 6),
            Text('${note.frequency.toStringAsFixed(2)} Hz · 허용 범위 ±50센트', style: const TextStyle(fontSize: 13, color: Color(0xFF66736E))),
          ]),
        ),
        const SizedBox(height: 24),
        const Row(children: [
          Icon(Icons.horizontal_rule, size: 18, color: Color(0xFF168577)),
          SizedBox(width: 6), Text('내 음높이', style: TextStyle(fontSize: 12)),
          Spacer(), Text('점선: 목표 음', style: TextStyle(fontSize: 12, color: Color(0xFF66736E))),
        ]),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3E9E6)), boxShadow: const [BoxShadow(color: Color(0x09203A34), blurRadius: 18, offset: Offset(0, 6))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(16), child: SizedBox(
          height: 230,
          child: AnimatedBuilder(animation: _scroll, builder: (context, child) => CustomPaint(
            painter: _SoundPainter(List.of(_history), pitch: true, inTune: inTune, pulse: MediaQuery.disableAnimationsOf(context) ? 0.5 : _scroll.value, shift: _running ? ((_clock.elapsedMilliseconds - _lastPointMs) / 93).clamp(0.0, 1.0) : 0),
          )),
        ))),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: inTune ? const Color(0xFFCBEDE2) : const Color(0xFFE4F2EE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: inTune ? const Color(0xFF71C6AE) : Colors.transparent),
            boxShadow: inTune ? const [BoxShadow(color: Color(0x20168577), blurRadius: 14)] : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_running && cents != null && cents.abs() <= 50 ? Icons.check_circle_outline : !_running ? Icons.pause_circle_outline : cents == null ? Icons.mic_none : cents > 0 ? Icons.arrow_upward : Icons.arrow_downward, color: const Color(0xFF168577), size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(!_running ? _status : cents == null ? '목소리를 내보세요' : cents.abs() <= 50 ? '목표 범위예요' : cents > 0 ? '목표보다 높아요' : '목표보다 낮아요',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF203A34)))),
          ]),
        ),
        const SizedBox(height: 4),
        Text(_pitch == null ? '음높이를 기다리고 있어요' : TargetNote.fromFrequency(_pitch!).vocalLabel,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF203A34))),
        if (_pitch != null) ...[
          const SizedBox(height: 4),
          Text('현재 ${_pitch!.toStringAsFixed(1)} Hz', textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF66736E))),
        ],
        const SizedBox(height: 28),
        const Text('앱 활성 연습 시간', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF66736E))),
        Text(_elapsedLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Color(0xFF203A34), fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: const Color(0xFF203A34)),
            onPressed: _busy || _completed ? null : () => _running ? _pause() : _start(),
            icon: Icon(_running ? Icons.pause : Icons.play_arrow),
            label: Text(_running ? '일시정지' : '이어하기'),
          )),
          const SizedBox(width: 12),
          Expanded(child: FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 52), backgroundColor: const Color(0xFF168577)),
            onPressed: _busy || _practiceTimer.elapsed.inMilliseconds < 20000 ? null : _complete,
            child: Text(_busy ? '처리 중…' : _completed ? '저장 재시도' : '연습 완료'),
          )),
        ]),
        const SizedBox(height: 10),
        Text(_practiceTimer.elapsed.inSeconds < 20 ? '완료까지 ${20 - _practiceTimer.elapsed.inSeconds}초' : '원하는 때 완료 버튼을 눌러 주세요',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF66736E))),
        const SizedBox(height: 20),
        Center(child: TextButton(onPressed: _busy ? null : _end, style: TextButton.styleFrom(foregroundColor: const Color(0xFF66736E)), child: const Text('연습 중단'))),
        const Text('일시정지·앱 비활성 시간은 제외해요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF66736E))),
      ])),
    ));
  }
}

class _SoundPainter extends CustomPainter {
  _SoundPainter(this.values, {this.pitch = false, this.shift = 0, this.inTune = false, this.pulse = 0});
  final bool inTune;
  final double pulse;
  final double shift;
  final List<double?> values;
  final bool pitch;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));
    for (final fraction in [0.2, 0.8]) {
      canvas.drawLine(Offset(0, size.height * fraction), Offset(size.width, size.height * fraction), Paint()..color = const Color(0xFFF0F4F2));
    }
    if (pitch) canvas.drawRect(Rect.fromLTRB(0, size.height * 0.45, size.width, size.height * 0.55), Paint()..color = inTune ? const Color(0xFFCBEDE2) : const Color(0xFFE4F2EE));
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(math.min(x + 6, size.width), size.height / 2), Paint()..color = const Color(0xFF93AAA2));
    }
    for (final entry in [('높음', 0.08), ('목표', 0.5), ('낮음', 0.9)]) {
      final label = TextPainter(text: TextSpan(text: entry.$1, style: const TextStyle(fontSize: 10, color: Color(0xFF789188))), textDirection: TextDirection.ltr)..layout();
      label.paint(canvas, Offset(10, size.height * entry.$2 - label.height / 2));
    }
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (pitch) canvas.translate((80 - values.length - shift) * size.width / 79, 0);
    for (var i=1;i<values.length;i++) {
      final a=values[i-1], b=values[i]; if(a==null||b==null) continue;
      double y(double v) => size.height/2 - (pitch ? v.clamp(-500,500)/1000 : v/2)*size.height;
      final start = Offset((i - 1) * size.width / (pitch ? 79 : values.length - 1), y(a));
      final end = Offset(i * size.width / (pitch ? 79 : values.length - 1), y(b));
      final matched = pitch && a.abs() <= 50 && b.abs() <= 50;
      if (matched) {
        canvas.drawLine(start, end, Paint()
          ..color = const Color(0x6654B99F)
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
      canvas.drawLine(start, end, Paint()
        ..color = matched ? const Color(0xFF149B80) : const Color(0xFF168577)
        ..strokeWidth = matched ? 4 : 2
        ..strokeCap = StrokeCap.round);
    }
    if (values.isNotEmpty && values.last != null) {
      final point = Offset((values.length - 1) * size.width / 79, size.height / 2 - values.last!.clamp(-500, 500) / 1000 * size.height);
      if (inTune) {
        final breathe = (1 - math.cos(pulse * 2 * math.pi)) / 2;
        canvas.drawCircle(point, 12 + breathe * 7, Paint()..color = const Color(0x18168577));
        canvas.drawCircle(point, 8 + breathe * 4, Paint()
          ..color = const Color(0xFF54B99F).withValues(alpha: 0.5 - breathe * 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      canvas.drawCircle(point, 8, Paint()..color = const Color(0x30168577));
      canvas.drawCircle(point, 4, Paint()..color = const Color(0xFF168577));
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SoundPainter oldDelegate) => true;
}
