import 'package:flutter/material.dart';

import '../models/target_note.dart';

class TargetNotePicker extends StatelessWidget {
  const TargetNotePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final octave = value ~/ 12 - 3;
    final pitchClass = value % 12;
    return Column(
      children: [
        DropdownButtonFormField<int>(
          key: ValueKey('octave-$octave'),
          initialValue: octave,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: '1. 옥타브 선택',
            border: OutlineInputBorder(),
          ),
          items: [
            for (var number = 1; number <= 3; number++)
              DropdownMenuItem(
                value: number,
                child: Text('$number옥타브 (C${number + 2}–B${number + 2})'),
              ),
          ],
          onChanged: (number) {
            if (number != null) onChanged((number + 3) * 12 + pitchClass);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          key: ValueKey('note-$value'),
          initialValue: pitchClass,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: '2. 목표 음 선택',
            prefixIcon: Icon(Icons.music_note_rounded),
            border: OutlineInputBorder(),
          ),
          items: [
            for (var pitch = 0; pitch < 12; pitch++)
              DropdownMenuItem(
                value: pitch,
                child: Text(TargetNote((octave + 3) * 12 + pitch).label),
              ),
          ],
          onChanged: (pitch) {
            if (pitch != null) onChanged((octave + 3) * 12 + pitch);
          },
        ),
      ],
    );
  }
}
