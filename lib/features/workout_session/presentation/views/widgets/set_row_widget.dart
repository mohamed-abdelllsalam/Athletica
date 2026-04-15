import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/workout_session/domain/entities/set_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SetRowWidget extends StatefulWidget {
  const SetRowWidget({
    super.key,
    required this.entry,
    required this.onKgChanged,
    required this.onRepsChanged,
    required this.onToggleComplete,
  });

  final SetEntry entry;
  final ValueChanged<int> onKgChanged;
  final ValueChanged<int> onRepsChanged;
  final VoidCallback onToggleComplete;

  @override
  State<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends State<SetRowWidget> {
  late final TextEditingController _kgController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _kgController = TextEditingController(
      text: widget.entry.kg > 0 ? '${widget.entry.kg}' : '',
    );
    _repsController = TextEditingController(
      text: widget.entry.reps > 0 ? '${widget.entry.reps}' : '',
    );
  }

  @override
  void dispose() {
    _kgController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          _SetBox(number: widget.entry.setNumber),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Text(
              widget.entry.previous,
              style: AppTextStyles.medium13(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              widget.entry.target,
              style: AppTextStyles.medium13(context)
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          _NumberInput(
            controller: _kgController,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) widget.onKgChanged(n);
            },
          ),
          SizedBox(width: 6.w),
          _NumberInput(
            controller: _repsController,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) widget.onRepsChanged(n);
            },
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: widget.onToggleComplete,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.entry.isCompleted
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                border: Border.all(
                  color: widget.entry.isCompleted
                      ? AppColors.primaryBlue
                      : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: widget.entry.isCompleted
                  ? Icon(Icons.check, color: AppColors.textPrimary, size: 16.sp)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetBox extends StatelessWidget {
  const _SetBox({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textTertiary, width: 1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.medium13(context)
            .copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 32.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.medium13(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
