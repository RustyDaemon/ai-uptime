import 'package:flutter/widgets.dart';

import '../tokens.dart';
import 'icon_glyph.dart';
import 'pressable.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;
  const AppDropdownItem({required this.value, required this.label});
}

class AppDropdown<T> extends StatefulWidget {
  final T value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final double minMenuWidth;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.minMenuWidth = 120,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _openMenu() {
    if (_entry != null) return;
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;

    _entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => _closeMenu(),
              child: const SizedBox.expand(),
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 4),
            child: _Menu(
              items: widget.items,
              selected: widget.value,
              minWidth: size.width < widget.minMenuWidth
                  ? widget.minMenuWidth
                  : size.width,
              onPick: (v) {
                _closeMenu();
                widget.onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  void _closeMenu() {
    _entry?.remove();
    _entry = null;
  }

  String _currentLabel() {
    for (final i in widget.items) {
      if (i.value == widget.value) return i.label;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Pressable(
        onTap: _openMenu,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        backgroundColor: AppColors.panel,
        border: Border.all(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_currentLabel(), style: AppText.body),
            const SizedBox(width: 6),
            IconGlyph.chevronDown(size: 12, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}

class _Menu<T> extends StatefulWidget {
  final List<AppDropdownItem<T>> items;
  final T selected;
  final double minWidth;
  final ValueChanged<T> onPick;

  const _Menu({
    required this.items,
    required this.selected,
    required this.minWidth,
    required this.onPick,
  });

  @override
  State<_Menu<T>> createState() => _MenuState<T>();
}

class _MenuState<T> extends State<_Menu<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * -4),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: Alignment.topRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.minWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.borderStrong),
              boxShadow: AppShadows.panel,
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in widget.items)
                    Pressable(
                      onTap: () => widget.onPick(item.value),
                      borderRadius: BorderRadius.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            child: item.value == widget.selected
                                ? IconGlyph.check(size: 12, color: AppColors.ok)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item.label, style: AppText.body),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
