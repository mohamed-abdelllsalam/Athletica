import 'invite_code_components.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/home/domain/entities/coach_invite_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small dialog that reveals the 6-character invite code with a staggered
/// animation and lets the coach copy the code. The Regenerate button is
/// static for now — wiring comes later.
class InviteCodeDialog extends StatefulWidget {
  const InviteCodeDialog({super.key, required this.invite});

  final CoachInviteCode invite;

  @override
  State<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends State<InviteCodeDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<double>> _popAnimations;

  static const int _perDigitDurationMs = 90;

  @override
  void initState() {
    super.initState();
    final digits = _codeChars.length;
    final totalMs = (digits * _perDigitDurationMs + 350).clamp(400, 1500);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    )..forward();

    CurvedAnimation digitAnimation(int index, Curve curve) {
      final start = (index * _perDigitDurationMs) / totalMs;
      final end = (start + 320 / totalMs).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: curve),
      );
    }

    // easeOutBack overshoots above 1 — used for the scale pop only, never
    // chained into another curve. Fade/slide stay within [0, 1].
    _fadeAnimations = List.generate(
      digits,
      (i) => digitAnimation(i, Curves.easeOut),
    );
    _popAnimations = List.generate(
      digits,
      (i) => digitAnimation(i, Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _codeChars =>
      widget.invite.code.trim().toUpperCase().split('');

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.invite.code.trim()));
    _showCopied('Code copied to clipboard.');
  }

  void _showCopied(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _expiryLabel {
    final expiresAt = widget.invite.expiresAt;
    if (expiresAt == null) return 'This code does not expire.';
    final hour12 = expiresAt.hour % 12 == 0 ? 12 : expiresAt.hour % 12;
    final period = expiresAt.hour < 12 ? 'AM' : 'PM';
    final date =
        '${expiresAt.year}-${expiresAt.month.toString().padLeft(2, '0')}-${expiresAt.day.toString().padLeft(2, '0')}';
    return 'Expires on $date at $hour12:${expiresAt.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Invite Client',
              textAlign: TextAlign.center,
              style: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Share this code with your client so they can connect with you.',
              textAlign: TextAlign.center,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Row(
                children: List.generate(_codeChars.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: CoachInviteCodeDigit(
                        fade: _fadeAnimations[index],
                        pop: _popAnimations[index],
                        character: _codeChars[index],
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _expiryLabel,
              textAlign: TextAlign.center,
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textTertiary),
            ),
            SizedBox(height: 24.h),
            CoachInviteDialogButton(
              label: 'Copy Code',
              icon: Icons.copy_rounded,
              onTap: _copyCode,
            ),
            SizedBox(height: 10.h),
            CoachInviteDialogButton(
              label: 'Regenerate',
              icon: Icons.refresh_rounded,
              onTap: () {},
              outlined: true,
            ),
            SizedBox(height: 6.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
