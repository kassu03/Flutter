import 'package:flutter/material.dart';

class PhoneViewport extends StatelessWidget {
  const PhoneViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFE5E7E4),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 412, maxHeight: 860),
        child: LayoutBuilder(
          builder: (context, constraints) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
            child: ClipRect(child: child),
          ),
        ),
      ),
    ),
  );
}
