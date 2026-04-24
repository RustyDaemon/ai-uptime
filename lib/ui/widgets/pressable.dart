import 'package:flutter/widgets.dart';

import '../tokens.dart';

class Pressable extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? pressedColor;
  final Border? border;
  final bool showHighlight;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadii.sm)),
    this.padding,
    this.backgroundColor,
    this.hoverColor,
    this.pressedColor,
    this.border,
    this.showHighlight = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final Color base = widget.backgroundColor ?? const Color(0x00000000);
    final Color hover = widget.hoverColor ?? AppColors.panel;
    final Color pressed = widget.pressedColor ?? AppColors.panelStrong;
    final Color current = !enabled || !widget.showHighlight
        ? base
        : _pressed
        ? pressed
        : _hovered
        ? hover
        : base;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onPointerCancel: enabled
            ? (_) => setState(() => _pressed = false)
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: current,
              borderRadius: widget.borderRadius,
              border: widget.border,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
