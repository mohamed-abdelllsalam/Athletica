import 'coach_subscription_sections.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/coach_subscription_state.dart';
import 'package:athletica/features/coach/home/presentation/views/coach_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ---------------------------------------------------------------------------
// Data model — no Flutter imports needed if moved to domain; kept here since
// it's pure presentation data with no business logic.
// ---------------------------------------------------------------------------

class _PlanData {
  const _PlanData({
    required this.label,
    required this.headline,
    required this.clientCount,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.accentColor,
  });

  final String label;
  final String headline;
  final String clientCount;
  final String monthlyPrice;
  final String yearlyPrice;
  final Color accentColor;
}

const _plans = [
  _PlanData(
    label: 'Economic',
    headline: "Thousands of athletes. One platform. Let's get to work.",
    clientCount: '10 clients',
    monthlyPrice: '000.0',
    yearlyPrice: '000.0',
    accentColor: AppColors.primaryBlue,
  ),
  _PlanData(
    label: 'Pro',
    headline:
        "You've made the right call. Athletica Pro is where serious coaches grow their business",
    clientCount: '50 clients',
    monthlyPrice: '000.0',
    yearlyPrice: '000.0',
    accentColor: AppColors.primaryBlue,
  ),
  _PlanData(
    label: 'Business',
    headline:
        "This is where elite coaches belong. Welcome to Athletica Business — the best just got better",
    clientCount: 'unlimited clients',
    monthlyPrice: '000.0',
    yearlyPrice: '000.0',
    accentColor: AppColors.primaryBlue,
  ),
];

const _features = [
  'Full access to all exercises & videos',
  'Create customized workout plans',
  'Download videos to watch offline',
];

// ---------------------------------------------------------------------------

class CoachSubscriptionViewBody extends StatefulWidget {
  const CoachSubscriptionViewBody({super.key});

  @override
  State<CoachSubscriptionViewBody> createState() =>
      _CoachSubscriptionViewBodyState();
}

class _CoachSubscriptionViewBodyState extends State<CoachSubscriptionViewBody> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final plan = _plans[_selectedIndex];

    return BlocConsumer<CoachSubscriptionCubit, CoachSubscriptionState>(
      listener: (context, state) {
        if (state is CoachSubscriptionSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            CoachHomeView.routeName,
            (_) => false,
          );
        } else if (state is CoachSubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CoachSubscriptionLoading;

        return Scaffold(
          backgroundColor: AppColors.primaryAppColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoachSubscriptionTabs(
                    labels: _plans.map((plan) => plan.label).toList(),
                    selectedIndex: _selectedIndex,
                    onSelect: (i) => setState(() => _selectedIndex = i),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    plan.headline,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bold24(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 16.h),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                      children: [
                        const TextSpan(text: 'Assign workout plans to up to '),
                        TextSpan(
                          text: plan.clientCount,
                          style: TextStyle(color: plan.accentColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: AppColors.surfaceDark, thickness: 1),
                  SizedBox(height: 16.h),
                  ..._features.map(
                    (f) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            color: AppColors.primaryBlue,
                            size: 16.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            f,
                            style: AppTextStyles.medium14(
                              context,
                            ).copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CoachSubscriptionPricingCard(
                    label: 'Monthly',
                    price: plan.monthlyPrice,
                    period: 'EGP/Month',
                    accentColor: plan.accentColor,
                  ),
                  SizedBox(height: 12.h),
                  CoachSubscriptionPricingCard(
                    label: 'Yearly',
                    price: plan.yearlyPrice,
                    period: 'EGP/Year',
                    accentColor: plan.accentColor,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => context
                                .read<CoachSubscriptionCubit>()
                                .subscribe(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Subscribe Now',
                              style: AppTextStyles.semiBold15(
                                context,
                              ).copyWith(color: AppColors.textPrimary),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.regular13(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(
                            text:
                                'Still have Questions? get in touch with our ',
                          ),
                          TextSpan(
                            text: 'sales team.',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.textPrimary,
                              fontSize: AppTextStyles.regular13(
                                context,
                              ).fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
