import 'package:flutter/material.dart';

/// 반응형 레이아웃 유틸리티
/// MediaQuery 및 LayoutBuilder를 활용한 반응형 디자인 지원
class Responsive {
  /// 화면 너비 가져오기
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 화면 높이 가져오기
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// 화면 크기 가져오기
  static Size size(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// 화면 비율 가져오기
  static double aspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  /// 화면이 모바일인지 확인 (너비 < 600)
  static bool isMobile(BuildContext context) {
    return width(context) < 600;
  }

  /// 화면이 태블릿인지 확인 (600 <= 너비 < 1200)
  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= 600 && w < 1200;
  }

  /// 화면이 데스크톱인지 확인 (너비 >= 1200)
  static bool isDesktop(BuildContext context) {
    return width(context) >= 1200;
  }

  /// 화면 너비에 따른 컬럼 수 계산
  static int getColumnCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// 화면 크기에 따른 패딩 계산
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// 화면 크기에 따른 그리드 간격 계산
  static double getGridSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 32;
    }
  }

  /// 접근성: 터치 영역 최소 크기 보장
  static double getMinTouchTarget() {
    return 44.0; // iOS/Android 접근성 가이드라인
  }

  /// 접근성: 터치 영역이 충분한지 확인
  static bool isTouchTargetAdequate(double size) {
    return size >= getMinTouchTarget();
  }

  /// 접근성: 터치 영역을 최소 크기로 확장
  static double ensureMinTouchTarget(double size) {
    return size < getMinTouchTarget() ? getMinTouchTarget() : size;
  }

  /// 텍스트 스케일 팩터 가져오기 (접근성)
  static double getTextScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaler.scale(1.0);
  }

  /// 텍스트 스케일이 큰지 확인 (접근성)
  static bool isLargeText(BuildContext context) {
    return getTextScaleFactor(context) > 1.2;
  }

  /// 안전 영역(노치 등) 고려한 패딩
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// 화면 방향 확인
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// 세로 모드인지 확인
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// 가로 모드인지 확인
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }
}

/// 반응형 위젯 빌더
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// 반응형 값 선택
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (Responsive.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}
