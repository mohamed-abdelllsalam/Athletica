import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';

Future<String?> showGoogleRolePicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: const Color(0xFF100C20),
    builder: (context) => const _GoogleRolePickerSheet(),
  );
}

class _GoogleRolePickerSheet extends StatefulWidget {
  const _GoogleRolePickerSheet();

  @override
  State<_GoogleRolePickerSheet> createState() => _GoogleRolePickerSheetState();
}

class _GoogleRolePickerSheetState extends State<_GoogleRolePickerSheet> {
  String _role = 'client';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose who you are:',
              style: AppTextStyles.medium16(context).copyWith(color: Colors.white),
            ),
            const SizedBox(height: 20),
            _roleOption('client', 'Client'),
            const SizedBox(height: 12),
            _roleOption('coach', 'Coach'),
            const SizedBox(height: 22),
            CustomButton(
              text: 'Continue',
              onPressed: () => Navigator.pop(context, _role),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleOption(String value, String label) {
    final selected = _role == value;
    return InkWell(
      onTap: () => setState(() => _role = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1532),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bold20(context).copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
