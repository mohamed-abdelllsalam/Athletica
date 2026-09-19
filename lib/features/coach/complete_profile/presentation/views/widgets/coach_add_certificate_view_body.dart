import 'coach_certificate_form.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachAddCertificateViewBody extends StatefulWidget {
  const CoachAddCertificateViewBody({super.key});

  @override
  State<CoachAddCertificateViewBody> createState() =>
      _CoachAddCertificateViewBodyState();
}

class _CoachAddCertificateViewBodyState
    extends State<CoachAddCertificateViewBody> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCertificateCubit, AddCertificateState>(
      listener: (context, state) {
        if (state is AddCertificateSuccess) {
          Navigator.of(context).pop();
        } else if (state is AddCertificateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryAppColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Add Certificates',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: CoachCertificateForm(
              nameController: _nameController,
              descriptionController: _descriptionController,
              onUpload: () {},
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          child: BlocBuilder<AddCertificateCubit, AddCertificateState>(
            builder: (context, state) {
              final isSaving = state is AddCertificateSaving;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          context.read<AddCertificateCubit>().saveCertificate(
                            name: _nameController.text,
                            description: _descriptionController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    disabledBackgroundColor: AppColors.buttonColor.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTextStyles.semiBold15(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
