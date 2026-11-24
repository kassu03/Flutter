/// Accumulates active practice segments using a monotonic clock.
class PracticeTimer {
  final Stopwatch _watch = Stopwatch();
  Duration get elapsed => _watch.elapsed;
  void start() => _watch.start();
  void pause() => _watch.stop();
}
