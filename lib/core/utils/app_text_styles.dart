import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyles {
  static TextStyle extraBold30(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: getResponsiveFontSize(context, fontSize: 30),
  );
  static TextStyle extraBold45(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: getResponsiveFontSize(context, fontSize: 45),
    fontFamily: 'Inter',
    height: 0.65,
  );
  static TextStyle regular16(BuildContext context) => TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: getResponsiveFontSize(context, fontSize: 16),
  );
  static TextStyle medium16(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: getResponsiveFontSize(context, fontSize: 16),
  );
  static TextStyle medium15(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: getResponsiveFontSize(context, fontSize: 15),
  );

  static TextStyle medium13(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: getResponsiveFontSize(context, fontSize: 13),
  );

  static TextStyle regular13(BuildContext context) => TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: getResponsiveFontSize(context, fontSize: 13),
  );

  static TextStyle semiBold15(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: getResponsiveFontSize(context, fontSize: 15),
  );

  static TextStyle bold24(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: getResponsiveFontSize(context, fontSize: 24),
  );
  static TextStyle semiBold35(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: getResponsiveFontSize(context, fontSize: 35),
  );
  static TextStyle regular35(BuildContext context) => TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: getResponsiveFontSize(context, fontSize: 35),
  );

  static TextStyle meduim11(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: getResponsiveFontSize(context, fontSize: 11),
  );

  static TextStyle meduim12(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: getResponsiveFontSize(context, fontSize: 12),
  );

  static TextStyle semiBold10(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: getResponsiveFontSize(context, fontSize: 10),
  );

  static TextStyle bold20(BuildContext context) => TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: getResponsiveFontSize(context, fontSize: 20),
  );
}

double getResponsiveFontSize(BuildContext _, {required double fontSize}) {
  return fontSize.sp;
}
