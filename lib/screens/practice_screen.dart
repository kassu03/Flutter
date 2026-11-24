import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/pitch_worker.dart';
import '../models/target_note.dart';
import '../services/microphone_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.targetMidi});
  final int targetMidi;
  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _mic = MicrophoneService();
  final _worker = PitchWorker();
  late final AnimationController _scroll;
  final _clock = Stopwatch();
  int _lastPointMs = 0;
  bool _workerReady = false;
  final List<int> _buffer = [];
  final List<double?> _history = [];
  List<double> _wave = [];
  bool _busy = false, _running = false, _analyzing = false;
  double? _pitch;
  String _status = '마이크 준비 중';


  @override
  void initState() { super.initState(); WidgetsBinding.instance.addObserver(this);
    _scroll = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _clock.start();
    unawaited(_prepare()); }

  Future<void> _prepare() async {
    try {
      await _worker.start((pitch, wave) {
        _analyzing = false;
        if (!mounted || !_running) return;
        setState(() {
          _pitch = pitch; _wave = wave; _lastPointMs = _clock.elapsedMilliseconds;
          _history.add(pitch == null ? null : 1200 * math.log(pitch / TargetNote(widget.targetMidi).frequency) / math.ln2);
          if (_history.length > 80) _history.removeAt(0);
        });
      });
      _workerReady = true;
      if (mounted) await _start();
    } catch (_) { if (mounted) setState(() => _status = '분석 준비에 실패했어요. 화면을 다시 열어 주세요.'); }
  }

  Future<void> _start() async {
    setState(() { _busy = true; _status = '마이크 연결 중'; });
    try {
      final allowed = await _mic.start(onInput: () {}, onFailure: () => unawaited(_pause('입력이 중단됐어요. 다시 시도해 주세요.')), onData: _data);
      if (mounted) setState(() { _running = allowed; _status = allowed ? '목표 음에 맞춰 소리를 내 보세요.' : '마이크 권한을 허용해 주세요.'; });
    } catch (_) { if (mounted) setState(() => _status = '마이크 연결 실패 · 다시 시도해 주세요.'); }
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
    _worker.analyze(chunk);
  }

  Future<void> _pause([String message = '일시정지 · 이어하기를 눌러 주세요.']) async {
    _buffer.clear();
    try { await _mic.stop(); } catch (_) {}
    if (mounted) setState(() { _running = false; _pitch = null; _wave = []; _history.add(null); _status = message; });
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
  void didChangeAppLifecycleState(AppLifecycleState state) { if (state != AppLifecycleState.resumed && _running) unawaited(_pause()); }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); _worker.dispose(); _scroll.dispose(); _clock.stop(); unawaited(_mic.dispose()); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final note = TargetNote(widget.targetMidi);
    final cents = _history.isEmpty ? null : _history.last;
    return PopScope(canPop: false, onPopInvokedWithResult: (didPop, result) { if (!didPop) unawaited(_end()); }, child: Scaffold(
      appBar: AppBar(title: const Text('음높이 트레이닝'), leading: IconButton(onPressed: _end, icon: const Icon(Icons.close))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
        Text('목표 ${note.label}', style: Theme.of(context).textTheme.headlineSmall),
        Text('${note.frequency.toStringAsFixed(2)} Hz · ±50센트'),
        const SizedBox(height: 24),
        Text(_pitch == null ? '측정 불가' : '${_pitch!.toStringAsFixed(1)} Hz', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text(!_running ? _status : cents == null ? '소리를 기다리고 있어요.' : cents.abs() <= 50 ? '목표 범위 안이에요!' : cents > 0 ? '목표보다 높아요' : '목표보다 낮아요'),
        const SizedBox(height: 20),
        const Text('음높이 · 초록 영역이 목표 범위예요'),
        const SizedBox(height: 8),
        SizedBox(height: 220, child: AnimatedBuilder(animation: _scroll, builder: (context, child) => CustomPaint(painter: _SoundPainter(List.of(_history), pitch: true, shift: _running ? ((_clock.elapsedMilliseconds - _lastPointMs) / 93).clamp(0.0, 1.0) : 0)))),
        const SizedBox(height: 24), const Text('마이크 파형'),
        SizedBox(height: 80, child: CustomPaint(painter: _SoundPainter(_wave))),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: _busy ? null : () => _running ? _pause() : _start(), icon: Icon(_running ? Icons.pause : Icons.play_arrow), label: Text(_busy ? '연결 중…' : _running ? '연습 일시정지' : '연습 이어하기')),
        OutlinedButton(onPressed: _busy ? null : _end, child: const Text('연습 중단')),
        const Text('현재는 실시간 표시 단계예요. 시간·유지율·녹음 저장은 다음 단계에서 연결해요.', style: TextStyle(fontSize: 12)),
      ])),
    ));
  }
}

class _SoundPainter extends CustomPainter {
  _SoundPainter(this.values, {this.pitch = false, this.shift = 0});
  final double shift;
  final List<double?> values;
  final bool pitch;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF0F4F0));
    if (pitch) canvas.drawRect(Rect.fromLTRB(0, size.height * 0.45, size.width, size.height * 0.55), Paint()..color = const Color(0xFFB9DFC5));
    canvas.drawLine(Offset(0,size.height/2),Offset(size.width,size.height/2),Paint()..color=Colors.grey);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (pitch) canvas.translate((80 - values.length - shift) * size.width / 79, 0);
    for (var i=1;i<values.length;i++) {
      final a=values[i-1], b=values[i]; if(a==null||b==null) continue;
      double y(double v) => size.height/2 - (pitch ? v.clamp(-500,500)/1000 : v/2)*size.height;
      canvas.drawLine(Offset((i-1)*size.width/(pitch?79:values.length-1),y(a)),Offset(i*size.width/(pitch?79:values.length-1),y(b)),Paint()..color=(pitch && b.abs()<=50 ? Colors.green : const Color(0xFF27675D))..strokeWidth=2);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SoundPainter oldDelegate) => true;
}
