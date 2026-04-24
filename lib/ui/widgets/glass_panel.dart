import 'package:flutter/widgets.dart';

import '../tokens.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? glow;
  final double glowStrength;
  final bool strong;

  const GlassPanel({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.radius = AppRadii.md,
    this.glow,
    this.glowStrength = 0.4,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final fill = strong ? AppColors.panelStrong : AppColors.panel;
    final borderColor = strong ? AppColors.borderStrong : AppColors.border;
    final shadows = <BoxShadow>[];
    if (glow != null) {
      shadows.addAll(AppShadows.glow(glow!, strength: glowStrength));
    }
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: shadows.isEmpty ? null : shadows,
      ),
      child: child,
    );
  }
}
