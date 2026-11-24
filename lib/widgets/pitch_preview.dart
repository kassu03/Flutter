import 'package:flutter/material.dart';

class PitchPreview extends StatelessWidget {
  const PitchPreview({super.key, required this.targetLabel});
  final String targetLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E6DF)),
    ),
    child: Column(children: [
      const Text('—', style: TextStyle(fontSize: 40, color: Color(0xFF586761))),
      const Text('아직 측정하지 않았어요', style: TextStyle(color: Color(0xFF586761))),
      const SizedBox(height: 24),
      const Align(alignment: Alignment.centerLeft, child: Text('높음', style: TextStyle(fontSize: 12, color: Color(0xFF586761)))),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFE5EEE7),
          border: Border.symmetric(horizontal: BorderSide(color: Color(0xFF9AB6A7))),
        ),
        child: Text('목표 $targetLabel · ±50센트', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF214E44), fontSize: 12)),
      ),
      const SizedBox(height: 16),
      const Align(alignment: Alignment.centerLeft, child: Text('낮음', style: TextStyle(fontSize: 12, color: Color(0xFF586761)))),
      const SizedBox(height: 20),
      const Text('마이크가 연결되면 이 영역에\n실제 음높이 변화가 표시돼요.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.6, color: Color(0xFF586761))),
    ]),
  );
}
