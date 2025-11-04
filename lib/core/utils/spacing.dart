import 'package:flutter/material.dart';

/// 글로벌 스타일 컴포넌트: Padding, Margin 유틸
/// Design Guide 기반: 8dp 기본 단위 (4/8/12/16/24/32dp 사용)
class AppSpacing {
  // 기본 단위: 8dp
  static const double baseUnit = 8.0;

  // Spacing 값들
  static const double xs = 4.0; // 0.5 * baseUnit
  static const double sm = 8.0; // 1 * baseUnit
  static const double md = 12.0; // 1.5 * baseUnit
  static const double lg = 16.0; // 2 * baseUnit
  static const double xl = 24.0; // 3 * baseUnit
  static const double xxl = 32.0; // 4 * baseUnit

  // Border Radius
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusRound = 28.0; // FAB용

  // Card 패딩
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // 화면 패딩
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);

  // 섹션 간격
  static const double sectionSpacing = xl;

  // 아이템 간격
  static const double itemSpacing = md;

  // 터치 영역 최소 크기 (접근성)
  static const double minTouchTarget = 44.0;
}

/// Spacing 위젯 확장
extension SpacingExtension on Widget {
  /// Padding 추가 (모든 방향)
  Widget paddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  /// Padding 추가 (수평)
  Widget paddingHorizontal(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  /// Padding 추가 (수직)
  Widget paddingVertical(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }

  /// Padding 추가 (상단)
  Widget paddingTop(double padding) {
    return Padding(
      padding: EdgeInsets.only(top: padding),
      child: this,
    );
  }

  /// Padding 추가 (하단)
  Widget paddingBottom(double padding) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: this,
    );
  }

  /// Padding 추가 (좌측)
  Widget paddingLeft(double padding) {
    return Padding(
      padding: EdgeInsets.only(left: padding),
      child: this,
    );
  }

  /// Padding 추가 (우측)
  Widget paddingRight(double padding) {
    return Padding(
      padding: EdgeInsets.only(right: padding),
      child: this,
    );
  }

  /// AppSpacing을 사용한 간편 패딩
  Widget paddingAllSm() => paddingAll(AppSpacing.sm);
  Widget paddingAllMd() => paddingAll(AppSpacing.md);
  Widget paddingAllLg() => paddingAll(AppSpacing.lg);
  Widget paddingAllXl() => paddingAll(AppSpacing.xl);

  Widget paddingHorizontalSm() => paddingHorizontal(AppSpacing.sm);
  Widget paddingHorizontalMd() => paddingHorizontal(AppSpacing.md);
  Widget paddingHorizontalLg() => paddingHorizontal(AppSpacing.lg);

  Widget paddingVerticalSm() => paddingVertical(AppSpacing.sm);
  Widget paddingVerticalMd() => paddingVertical(AppSpacing.md);
  Widget paddingVerticalLg() => paddingVertical(AppSpacing.lg);
}
