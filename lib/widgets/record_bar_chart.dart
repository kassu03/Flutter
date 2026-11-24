import 'package:flutter/material.dart';

class RecordBarChart extends StatelessWidget {
  const RecordBarChart({super.key, required this.labels, required this.values, required this.maximum, required this.unit});
  final List<String> labels;
  final List<double?> values;
  final double maximum;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('0–${maximum.toStringAsFixed(0)}$unit', style: const TextStyle(fontSize: 12)),
    const SizedBox(height: 8),
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < values.length; i++)
          SizedBox(width: 54, child: Semantics(
            label: '${labels[i]}: ${values[i] == null ? '측정 시간 부족' : '${values[i]!.toStringAsFixed(1)}$unit'}',
            child: Column(children: [
              Text(values[i] == null ? '측정 부족' : values[i]!.toStringAsFixed(1), style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 4),
              SizedBox(height: 100, child: Align(alignment: Alignment.bottomCenter, child:
                values[i] == null ? const Text('—') : Container(
                  width: 20, height: 100 * (values[i]! / maximum).clamp(0, 1),
                  decoration: BoxDecoration(color: const Color(0xFF168577), borderRadius: BorderRadius.circular(4)),
                ))),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text(labels[i], style: const TextStyle(fontSize: 11)),
            ]),
          )),
      ]),
    ),
    const SizedBox(height: 8),
    const Text('좌우로 밀어 전체 보기', style: TextStyle(fontSize: 11, color: Color(0xFF586761))),
  ]);
}
