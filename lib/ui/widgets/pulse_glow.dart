import 'package:flutter/widgets.dart';

import '../tokens.dart';

class PulseGlow extends StatefulWidget {
  final bool enabled;
  final Color color;
  final double radius;
  final Widget child;

  const PulseGlow({
    super.key,
    required this.enabled,
    required this.color,
    required this.child,
    this.radius = AppRadii.md,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _startController();
  }

  @override
  void didUpdateWidget(covariant PulseGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && _ctrl == null) {
      _startController();
    } else if (!widget.enabled && _ctrl != null) {
      _ctrl?.dispose();
      _ctrl = null;
    }
  }

  void _startController() {
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _ctrl == null) return widget.child;
    return AnimatedBuilder(
      animation: _ctrl!,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_ctrl!.value);
        final strength = 0.25 + t * 0.55;
        final a = (strength.clamp(0.0, 1.0) * 255).round();
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(a),
                blurRadius: 22 + t * 10,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
