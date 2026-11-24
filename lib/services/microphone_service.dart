import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';

class MicrophoneService {
  final _recorder = AudioRecorder();
  StreamSubscription<dynamic>? _subscription;

  Future<bool> start({required void Function() onInput, required void Function() onFailure, void Function(Uint8List)? onData}) async {
    if (!await _recorder.hasPermission()) return false;
    final stream = await _recorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits, numChannels: 1, sampleRate: 44100,
    ));
    _subscription = stream.listen((data) {
      if (data.isNotEmpty) { onInput(); onData?.call(data); }
    }, onError: (Object error) => onFailure(), onDone: onFailure);
    return true;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _recorder.dispose();
  }
}
