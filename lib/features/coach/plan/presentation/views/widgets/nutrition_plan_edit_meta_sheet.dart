import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NutritionPlanEditMetaSheet extends StatefulWidget {
  const NutritionPlanEditMetaSheet({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.onSave,
  });

  final String initialName;
  final String initialDescription;
  final Future<String?> Function({
    required String title,
    required String description,
  })
  onSave;

  @override
  State<NutritionPlanEditMetaSheet> createState() =>
      _NutritionPlanEditMetaSheetState();
}

class _NutritionPlanEditMetaSheetState
    extends State<NutritionPlanEditMetaSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialDescription);
  bool _nameHasError = false;
  bool _descriptionHasError = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final nameError = name.isEmpty;
    final descriptionError = description.isEmpty;
    if (nameError || descriptionError) {
      setState(() {
        _nameHasError = nameError;
        _descriptionHasError = descriptionError;
      });
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(title: name, description: description);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Edit plan',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Plan Name',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10.r),
                border: _nameHasError
                    ? Border.all(color: Colors.redAccent)
                    : null,
              ),
              child: TextField(
                controller: _nameController,
                autofocus: true,
                onChanged: (_) {
                  if (_nameHasError && _nameController.text.trim().isNotEmpty) {
                    setState(() => _nameHasError = false);
                  }
                },
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Plan name',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Description',
              style: AppTextStyles.meduim12(
                context,
              ).copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(10.r),
                border: _descriptionHasError
                    ? Border.all(color: Colors.redAccent)
                    : null,
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onChanged: (_) {
                  if (_descriptionHasError &&
                      _descriptionController.text.trim().isNotEmpty) {
                    setState(() => _descriptionHasError = false);
                  }
                },
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a program description…',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 8.h),
              Text(
                _errorMessage!,
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: Colors.redAccent),
              ),
            ],
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
