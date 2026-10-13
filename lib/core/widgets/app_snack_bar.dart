import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class AppSnackBar {
  static SnackBar success({
    required Widget content,
    Duration? duration,
    SnackBarAction? action,
    SnackBarBehavior? behavior,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    DismissDirection? dismissDirection,
    VoidCallback? onVisible,
  }) {
    return SnackBar(
      content: content,
      backgroundColor: AppColors.success,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
      behavior: behavior,
      shape: shape,
      margin: margin,
      padding: padding,
      elevation: elevation,
      dismissDirection: dismissDirection,
      onVisible: onVisible,
    );
  }

  static SnackBar error({
    required Widget content,
    Duration? duration,
    SnackBarAction? action,
    SnackBarBehavior? behavior,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    DismissDirection? dismissDirection,
    VoidCallback? onVisible,
  }) {
    return SnackBar(
      content: content,
      backgroundColor: AppColors.error,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
      behavior: behavior,
      shape: shape,
      margin: margin,
      padding: padding,
      elevation: elevation,
      dismissDirection: dismissDirection,
      onVisible: onVisible,
    );
  }

  static SnackBar neutral({
    required Widget content,
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
    SnackBarBehavior? behavior,
    ShapeBorder? shape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    DismissDirection? dismissDirection,
    VoidCallback? onVisible,
  }) {
    return SnackBar(
      content: content,
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      action: action,
      behavior: behavior,
      shape: shape,
      margin: margin,
      padding: padding,
      elevation: elevation,
      dismissDirection: dismissDirection,
      onVisible: onVisible,
    );
  }
}
