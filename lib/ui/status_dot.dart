import 'package:flutter/widgets.dart';

import '../models/status_indicator.dart';
import 'tokens.dart';

class StatusDot extends StatelessWidget {
  final StatusIndicator indicator;
  final double size;

  const StatusDot({super.key, required this.indicator, this.size = 10});

  @override
  Widget build(BuildContext context) {
    final color = colorFor(indicator);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(140),
            blurRadius: size * 0.9,
            spreadRadius: 0.4,
          ),
        ],
      ),
    );
  }
}
