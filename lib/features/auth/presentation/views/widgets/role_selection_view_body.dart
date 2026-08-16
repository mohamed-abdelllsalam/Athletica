import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/sign_up_view.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class RoleSelectionViewBody extends StatefulWidget {
  const RoleSelectionViewBody({super.key});

  @override
  State<RoleSelectionViewBody> createState() => _RoleSelectionViewBodyState();
}

class _RoleSelectionViewBodyState extends State<RoleSelectionViewBody> {
  String selectedRole = 'Client';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 44),
            Center(
              child: Text(
                'Choose who you are :',
                style: AppTextStyles.medium16(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 28),
            _buildRoleCard(
              label: 'Client',
              icon: Image.asset('assets/images/on_boarding/client_icon.png'),
              isSelected: selectedRole == 'Client',
              onTap: () => setState(() => selectedRole = 'Client'),
            ),
            const SizedBox(height: 18),
            _buildRoleCard(
              label: 'Coach',
              icon: Image.asset('assets/images/on_boarding/coach_icon.png'),
              isSelected: selectedRole == 'Coach',
              onTap: () => setState(() => selectedRole = 'Coach'),
            ),
            const Spacer(),
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  SignUpView.routeName,
                  arguments: selectedRole,
                );
              },
              text: 'continue',
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String label,
    required Widget icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1532),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: SizedBox(width: 36, height: 36, child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bold20(
                    context,
                  ).copyWith(color: Colors.white),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryPurple
                        : const Color(0xFFB8B8B8),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
