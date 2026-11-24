import 'package:flutter/material.dart';
import '../models/target_note.dart';

class TargetNotePicker extends StatelessWidget {
  const TargetNotePicker({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final octave = value ~/ 12 - 3;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('옥타브', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF203A34))),
      const SizedBox(height: 12),
      Row(children: [
        for (var number = 1; number <= 3; number++) ...[
          if (number > 1) const SizedBox(width: 8),
          Expanded(child: _choice(
            selected: octave == number,
            onTap: () => onChanged((number + 3) * 12 + value % 12),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text('$number옥타브', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
          )),
        ],
      ]),
      const SizedBox(height: 24),
      const Text('목표 음', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF203A34))),
      const SizedBox(height: 12),
      for (var row = 0; row < 3; row++) ...[
        if (row > 0) const SizedBox(height: 8),
        Row(children: [
          for (var col = 0; col < 4; col++) ...[
            if (col > 0) const SizedBox(width: 8),
            Expanded(child: _choice(
              selected: value % 12 == row * 4 + col,
              onTap: () => onChanged((octave + 3) * 12 + row * 4 + col),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(children: [
                  Text(TargetNote.koreanNames[row * 4 + col], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(TargetNote.names[row * 4 + col], style: const TextStyle(fontSize: 11)),
                ]),
              ),
            )),
          ],
        ]),
      ],
    ]);
  }

  Widget _choice({required bool selected, required VoidCallback onTap, required Widget child}) {
    return Semantics(
      selected: selected, button: true,
      child: Material(
        color: selected ? const Color(0xFF168577) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: selected ? const Color(0xFF168577) : const Color(0xFFE0E7E3))),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: DefaultTextStyle.merge(
          style: TextStyle(color: selected ? Colors.white : const Color(0xFF425D54)),
          child: child,
        )),
      ),
    );
  }
}
