import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract final class CheckInUi {
  static const panel = Color(0xFF0E1118);
  static const question = Color(0xFF210B10);
  static const number = Color(0xFF35133B);
  static const numberText = Color(0xFF7A5CAD);
  static const violet = Color(0xFF8A38F5);
  static const selected = Color(0xFF3F42B8);
  static const note = Color(0xFF15181D);

  static TextStyle text(
    double size, {
    Color color = Colors.white,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: 1.5,
  );

  static InputDecoration input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: text(
      11,
      color: AppColors.textSecondary,
      weight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.transparent,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: violet),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6.r),
      borderSide: const BorderSide(color: Colors.white),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
  );
}

class CheckInAsset extends StatelessWidget {
  const CheckInAsset(this.name, {super.key, this.size = 22});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/check_in_$name.svg',
    width: size.w,
    height: size.w,
  );
}

class CheckInAvatar extends StatelessWidget {
  const CheckInAvatar({super.key, this.size = 45});
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.asset(
      'assets/icons/check_in_avatar.png',
      width: size.w,
      height: size.w,
      fit: BoxFit.cover,
      semanticLabel: 'Sample client avatar',
    ),
  );
}

class CheckInPreviewNotice extends StatelessWidget {
  const CheckInPreviewNotice({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    child: Text(
      'UI preview · Sample data · Nothing is sent',
      style: CheckInUi.text(
        10,
        color: AppColors.textSecondary,
        weight: FontWeight.w400,
      ),
    ),
  );
}

class CheckInButton extends StatelessWidget {
  const CheckInButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primaryBlue,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
      child: Text(label, style: CheckInUi.text(12)),
    ),
  );
}

class CheckInQuestionRow extends StatelessWidget {
  const CheckInQuestionRow({
    super.key,
    required this.index,
    required this.label,
    required this.child,
  });
  final int index;
  final String label;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minHeight: 60.h),
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: CheckInUi.question,
      borderRadius: BorderRadius.circular(5.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: CheckInUi.number,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: CheckInUi.text(12, color: CheckInUi.numberText),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(flex: 3, child: Text(label, style: CheckInUi.text(11))),
        SizedBox(width: 8.w),
        Flexible(flex: 2, child: child),
      ],
    ),
  );
}

class CheckInEntryCard extends StatelessWidget {
  const CheckInEntryCard({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Material(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.r),
        side: const BorderSide(color: AppColors.primaryBlue),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          child: Row(
            children: [
              const Icon(
                Icons.check_box_outlined,
                color: AppColors.primaryBlue,
                size: 26,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-ins', style: CheckInUi.text(12)),
                    Text(
                      'View your check-ins & responses · Preview',
                      style: CheckInUi.text(9),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    ),
  );
}

class CheckInPage extends StatelessWidget {
  const CheckInPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigationBar,
  });
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Navigator.canPop(context)
          ? IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const CheckInAsset('back', size: 20),
            )
          : null,
      title: Text(title, style: CheckInUi.text(20)),
      actions: actions,
    ),
    body: SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CheckInPreviewNotice(),
          Expanded(child: child),
        ],
      ),
    ),
    bottomNavigationBar: bottomNavigationBar,
  );
}
