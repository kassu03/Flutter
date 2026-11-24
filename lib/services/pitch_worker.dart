import 'dart:isolate';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:pitch_detector_dart/pitch_detector.dart';

class PitchWorker {
  Isolate? _isolate;
  SendPort? _input;
  final _results = ReceivePort();
  Future<void> start(void Function(double?, List<double>) onResult) async {
    final ready = ReceivePort();
    _isolate = await Isolate.spawn(_run, ready.sendPort);
    _input = await ready.first as SendPort;
    ready.close();
    _results.listen((message) {
      final result = message as List;
      onResult(result[0] as double?, (result[1] as List).cast<double>());
    });
  }
  void analyze(Uint8List data) => _input?.send([_results.sendPort, data]);
  void dispose() { _isolate?.kill(priority: Isolate.immediate); _results.close(); }
}

void _run(SendPort ready) {
  final input = ReceivePort();
  final detector = PitchDetector(bufferSize: 4096);
  ready.send(input.sendPort);
  input.listen((message) async {
    final reply = message[0] as SendPort;
    try {
      final bytes = ByteData.sublistView(message[1] as Uint8List);
      final samples = List.generate(4096, (i) => bytes.getInt16(i * 2, Endian.little) / 32768);
      final rms = math.sqrt(samples.fold<double>(0, (sum, x) => sum + x*x) / samples.length);
      final result = await detector.getPitchFromFloatBuffer(samples);
      final pitch = rms > 0.01 && result.pitched && result.probability > 0.8 && result.pitch > 0 ? result.pitch : null;
      reply.send([pitch, List.generate(160, (i) => samples[i * 25])]);
    } catch (_) { reply.send([null, <double>[]]); }
  });
}
