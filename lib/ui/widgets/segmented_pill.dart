import 'package:flutter/widgets.dart';

import '../tokens.dart';
import 'pressable.dart';

class SegmentOption<T> {
  final T value;
  final String label;
  const SegmentOption({required this.value, required this.label});
}

class SegmentedPill<T> extends StatelessWidget {
  final List<SegmentOption<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  const SegmentedPill({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = segments.length;
        final segWidth = width / count;
        final selectedIdx = segments
            .indexWhere((s) => s.value == selected)
            .clamp(0, count - 1);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: selectedIdx * segWidth + 2,
                top: 2,
                bottom: 2,
                width: segWidth - 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.panelStrong,
                    borderRadius: BorderRadius.circular(height / 2),
                    border: Border.all(color: AppColors.borderStrong),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33FFFFFF),
                        blurRadius: 6,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: Pressable(
                        showHighlight: false,
                        borderRadius: BorderRadius.circular(height / 2),
                        onTap: () => onChanged(segments[i].value),
                        child: SizedBox(
                          height: height,
                          child: Center(
                            child: Text(
                              segments[i].label,
                              style: AppText.label.copyWith(
                                color: i == selectedIdx
                                    ? AppColors.text
                                    : AppColors.textDim,
                                fontWeight: i == selectedIdx
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
