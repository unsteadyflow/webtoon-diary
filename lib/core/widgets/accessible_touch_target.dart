import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../utils/spacing.dart';

/// 접근성을 고려한 터치 영역 위젯
/// 최소 44px 터치 영역 보장
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? minSize;
  final EdgeInsets? padding;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final minTouchSize = minSize ?? Responsive.getMinTouchTarget();
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.sm);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          constraints: BoxConstraints(
            minWidth: minTouchSize,
            minHeight: minTouchSize,
          ),
          padding: effectivePadding,
          child: child,
        ),
      ),
    );
  }
}

/// 접근성 버튼 래퍼
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? minSize;
  final ButtonStyle? style;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.minSize,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final minTouchSize = minSize ?? Responsive.getMinTouchTarget();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minTouchSize,
        minHeight: minTouchSize,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// 접근성 아이콘 버튼 래퍼
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double? iconSize;
  final double? minSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.iconSize,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    final minTouchSize = minSize ?? Responsive.getMinTouchTarget();
    final effectiveIconSize = iconSize ?? 24.0;

    return SizedBox(
      width: minTouchSize,
      height: minTouchSize,
      child: IconButton(
        icon: Icon(icon, size: effectiveIconSize),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
