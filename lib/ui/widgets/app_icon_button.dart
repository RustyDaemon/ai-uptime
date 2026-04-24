import 'package:flutter/widgets.dart';

import '../tokens.dart';
import 'icon_glyph.dart';
import 'pressable.dart';

class AppIconButton extends StatelessWidget {
  final IconGlyphKind glyph;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.glyph,
    required this.onTap,
    this.size = 24,
    this.iconSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: IconGlyph(
            kind: glyph,
            size: iconSize,
            color: AppColors.textDim,
          ),
        ),
      ),
    );
  }
}
