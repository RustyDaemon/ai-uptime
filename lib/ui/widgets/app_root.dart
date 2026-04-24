import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config.dart';
import '../../state/providers.dart';
import '../tokens.dart';

class AppRoot extends ConsumerWidget {
  final Widget child;

  const AppRoot({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final scale = ref.watch(settingsProvider.select((s) => s.textScale));
    applyAppTheme(AppTheme.forMode(mode), scale: scale.factor);

    return WidgetsApp(
      title: appTitle,
      color: AppColors.bg0,
      debugShowCheckedModeBanner: false,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return _NoAnimationPageRoute<T>(
          settings: settings,
          pageBuilder: (ctx, a1, a2) => builder(ctx),
        );
      },
      home: DefaultTextStyle(
        style: AppText.body,
        child: IconTheme(
          data: IconThemeData(color: AppColors.text, size: 16),
          child: child,
        ),
      ),
    );
  }
}

class _NoAnimationPageRoute<T> extends PageRoute<T> {
  _NoAnimationPageRoute({
    required RouteSettings settings,
    required this.pageBuilder,
  }) : super(settings: settings);

  final RoutePageBuilder pageBuilder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(context, animation, secondaryAnimation);
  }
}
