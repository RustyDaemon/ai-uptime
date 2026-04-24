import 'package:flutter/widgets.dart';

import '../models/status_indicator.dart';

enum AppThemeMode {
  dark('dark', 'Dark'),
  light('light', 'Light');

  final String id;
  final String label;
  const AppThemeMode(this.id, this.label);

  static AppThemeMode fromId(String? id) =>
      values.firstWhere((m) => m.id == id, orElse: () => AppThemeMode.dark);
}

enum AppTextScale {
  small('small', 'Small', 0.9),
  medium('medium', 'Medium', 1.0),
  large('large', 'Large', 1.12),
  xlarge('xlarge', 'Extra large', 1.25);

  final String id;
  final String label;
  final double factor;
  const AppTextScale(this.id, this.label, this.factor);

  static AppTextScale fromId(String? id) =>
      values.firstWhere((s) => s.id == id, orElse: () => AppTextScale.medium);
}

class AppColors {
  AppColors._();

  static Color bg0 = const Color(0xFF0A0B10);
  static Color bg1 = const Color(0xFF12141C);
  static Color bg2 = const Color(0xFF1A1D28);

  static Color panel = const Color(0x14FFFFFF);
  static Color panelStrong = const Color(0x1FFFFFFF);
  static Color panelHover = const Color(0x1AFFFFFF);

  static Color border = const Color(0x1FFFFFFF);
  static Color borderStrong = const Color(0x33FFFFFF);

  static Color text = const Color(0xFFF5F6FA);
  static Color textDim = const Color(0xB3F5F6FA);
  static Color textFaint = const Color(0x80F5F6FA);

  static Color highlight = const Color(0x22FFFFFF);

  static Color ok = const Color(0xFF22C55E);
  static Color maintenance = const Color(0xFF3B82F6);
  static Color degraded = const Color(0xFFEAB308);
  static Color partial = const Color(0xFFF97316);
  static Color major = const Color(0xFFEF4444);
  static Color unknown = const Color(0xFF8C8C8C);
}

class AppRadii {
  const AppRadii._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
}

class AppSpacing {
  const AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> panel = const [
    BoxShadow(color: Color(0x99000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static List<BoxShadow> glow(Color color, {double strength = 0.5}) {
    final a = (strength.clamp(0.0, 1.0) * 255).round();
    return [
      BoxShadow(color: color.withAlpha(a), blurRadius: 18, spreadRadius: 0.5),
    ];
  }
}

class AppText {
  AppText._();

  static String? family = 'JetBrainsMono';

  static TextStyle title = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Color(0xFFF5F6FA),
    letterSpacing: 0.2,
    height: 1.15,
  );

  static TextStyle body = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFFF5F6FA),
    height: 1.25,
  );

  static TextStyle bodyDim = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: Color(0xB3F5F6FA),
    height: 1.3,
  );

  static TextStyle label = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xFFF5F6FA),
    letterSpacing: 0.3,
    height: 1.2,
  );

  static TextStyle tag = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    color: Color(0x80F5F6FA),
    letterSpacing: 1.0,
    height: 1.2,
  );

  static TextStyle updateTime = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: Color(0x80F5F6FA),
    height: 1.2,
  );

  static TextStyle incidentTitle = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFFF5F6FA),
    height: 1.3,
  );

  static TextStyle incidentBody = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: Color(0xB3F5F6FA),
    height: 1.4,
  );
}

class AppTheme {
  final Color bg0;
  final Color bg1;
  final Color bg2;
  final Color panel;
  final Color panelStrong;
  final Color panelHover;
  final Color border;
  final Color borderStrong;
  final Color text;
  final Color textDim;
  final Color textFaint;
  final Color highlight;
  final Color ok;
  final Color maintenance;
  final Color degraded;
  final Color partial;
  final Color major;
  final Color unknown;
  final List<BoxShadow> panelShadow;
  final String? fontFamily;

  const AppTheme({
    required this.bg0,
    required this.bg1,
    required this.bg2,
    required this.panel,
    required this.panelStrong,
    required this.panelHover,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.highlight,
    required this.ok,
    required this.maintenance,
    required this.degraded,
    required this.partial,
    required this.major,
    required this.unknown,
    required this.panelShadow,
    required this.fontFamily,
  });

  static const AppTheme dark = AppTheme(
    bg0: Color(0xFF0A0B10),
    bg1: Color(0xFF12141C),
    bg2: Color(0xFF1A1D28),
    panel: Color(0x14FFFFFF),
    panelStrong: Color(0x1FFFFFFF),
    panelHover: Color(0x1AFFFFFF),
    border: Color(0x1FFFFFFF),
    borderStrong: Color(0x33FFFFFF),
    text: Color(0xFFF5F6FA),
    textDim: Color(0xB3F5F6FA),
    textFaint: Color(0x80F5F6FA),
    highlight: Color(0x22FFFFFF),
    ok: Color(0xFF22C55E),
    maintenance: Color(0xFF3B82F6),
    degraded: Color(0xFFEAB308),
    partial: Color(0xFFF97316),
    major: Color(0xFFEF4444),
    unknown: Color(0xFF8C8C8C),
    panelShadow: [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    fontFamily: 'JetBrainsMono',
  );

  static const AppTheme light = AppTheme(
    bg0: Color(0xFFFAFBFD),
    bg1: Color(0xFFF1F3F8),
    bg2: Color(0xFFE6E9F1),
    panel: Color(0x0F0B0D14),
    panelStrong: Color(0x1A0B0D14),
    panelHover: Color(0x140B0D14),
    border: Color(0x1F0B0D14),
    borderStrong: Color(0x330B0D14),
    text: Color(0xFF0B0D14),
    textDim: Color(0xAD0B0D14),
    textFaint: Color(0x800B0D14),
    highlight: Color(0x14FFFFFF),
    ok: Color(0xFF16A34A),
    maintenance: Color(0xFF2563EB),
    degraded: Color(0xFFCA8A04),
    partial: Color(0xFFEA580C),
    major: Color(0xFFDC2626),
    unknown: Color(0xFF6B7280),
    panelShadow: [
      BoxShadow(
        color: Color(0x22000000),
        blurRadius: 24,
        offset: Offset(0, 12),
      ),
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
    fontFamily: null,
  );

  static AppTheme forMode(AppThemeMode mode) =>
      mode == AppThemeMode.light ? light : dark;
}

void applyAppTheme(AppTheme t, {double scale = 1.0}) {
  AppColors.bg0 = t.bg0;
  AppColors.bg1 = t.bg1;
  AppColors.bg2 = t.bg2;
  AppColors.panel = t.panel;
  AppColors.panelStrong = t.panelStrong;
  AppColors.panelHover = t.panelHover;
  AppColors.border = t.border;
  AppColors.borderStrong = t.borderStrong;
  AppColors.text = t.text;
  AppColors.textDim = t.textDim;
  AppColors.textFaint = t.textFaint;
  AppColors.highlight = t.highlight;
  AppColors.ok = t.ok;
  AppColors.maintenance = t.maintenance;
  AppColors.degraded = t.degraded;
  AppColors.partial = t.partial;
  AppColors.major = t.major;
  AppColors.unknown = t.unknown;

  AppShadows.panel = t.panelShadow;

  AppText.family = t.fontFamily;
  AppText.title = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 13 * scale,
    fontWeight: FontWeight.w700,
    color: t.text,
    letterSpacing: 0.2,
    height: 1.15,
  );
  AppText.body = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 12 * scale,
    fontWeight: FontWeight.w500,
    color: t.text,
    height: 1.25,
  );
  AppText.bodyDim = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 11.5 * scale,
    fontWeight: FontWeight.w500,
    color: t.textDim,
    height: 1.3,
  );
  AppText.label = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 11 * scale,
    fontWeight: FontWeight.w500,
    color: t.text,
    letterSpacing: 0.3,
    height: 1.2,
  );
  AppText.tag = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 9.5 * scale,
    fontWeight: FontWeight.w700,
    color: t.textFaint,
    letterSpacing: 1.0,
    height: 1.2,
  );
  AppText.updateTime = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 10 * scale,
    fontWeight: FontWeight.w500,
    color: t.textFaint,
    height: 1.2,
  );
  AppText.incidentTitle = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 12.5 * scale,
    fontWeight: FontWeight.w600,
    color: t.text,
    height: 1.3,
  );
  AppText.incidentBody = TextStyle(
    fontFamily: t.fontFamily,
    fontSize: 11 * scale,
    fontWeight: FontWeight.w500,
    color: t.textDim,
    height: 1.4,
  );
}

Color colorFor(StatusIndicator s) {
  switch (s) {
    case StatusIndicator.operational:
      return AppColors.ok;
    case StatusIndicator.maintenance:
      return AppColors.maintenance;
    case StatusIndicator.degraded:
      return AppColors.degraded;
    case StatusIndicator.partial:
      return AppColors.partial;
    case StatusIndicator.major:
      return AppColors.major;
    case StatusIndicator.unknown:
      return AppColors.unknown;
  }
}

bool isIssue(StatusIndicator s) =>
    s == StatusIndicator.degraded ||
    s == StatusIndicator.partial ||
    s == StatusIndicator.major;
