import 'package:flutter/widgets.dart';

import '../tokens.dart';

class ThinDivider extends StatelessWidget {
  final double leftInset;
  final double rightInset;
  final Color? color;
  final double height;

  const ThinDivider({
    super.key,
    this.leftInset = 0,
    this.rightInset = 0,
    this.color,
    this.height = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftInset, right: rightInset),
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color ?? AppColors.border),
        ),
      ),
    );
  }
}
