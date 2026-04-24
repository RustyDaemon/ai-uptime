import 'package:flutter/widgets.dart';

import '../tokens.dart';
import 'pressable.dart';

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({super.key, required this.value, required this.onChanged});

  static const double _trackW = 34;
  static const double _trackH = 18;
  static const double _thumb = 12;

  @override
  Widget build(BuildContext context) {
    final Color trackFill = value
        ? AppColors.ok.withAlpha(56)
        : AppColors.panel;
    final Color trackBorder = value ? AppColors.ok : AppColors.border;
    final Color thumbColor = value ? AppColors.ok : AppColors.textDim;

    return Pressable(
      showHighlight: false,
      borderRadius: BorderRadius.circular(_trackH / 2),
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: _trackW,
        height: _trackH,
        decoration: BoxDecoration(
          color: trackFill,
          borderRadius: BorderRadius.circular(_trackH / 2),
          border: Border.all(color: trackBorder, width: 1),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.ok.withAlpha(90),
                    blurRadius: 10,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: value
                        ? [
                            BoxShadow(
                              color: AppColors.ok.withAlpha(160),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
