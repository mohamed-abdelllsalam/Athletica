import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_card.dart';
import 'package:athletica/features/home/presentation/views/widgets/workout_data.dart';
import 'package:athletica/features/workout_session/presentation/views/workout_session_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutsSection extends StatefulWidget {
  const WorkoutsSection({super.key});

  @override
  State<WorkoutsSection> createState() => _WorkoutsSectionState();
}

class _WorkoutsSectionState extends State<WorkoutsSection> {
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"Show up even on the days\nyou don\'t feel like it — that\'s\nwhere the real transformation\nbegins. I\'m not just training\nyour body, I\'m building your\ndiscipline',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.primaryBlue, height: 1.3),
          ),
          SizedBox(height: 24.h),
          _DayPicker(
            selectedDay: _selectedDay,
            onChanged: (day) => setState(() => _selectedDay = day),
          ),
          SizedBox(height: 16.h),
          ...workoutsByDay[_selectedDay - 1].asMap().entries.map(
            (entry) => WorkoutCard(
              name: entry.value.name,
              sets: entry.value.sets,
              repsRange: entry.value.repsRange,
              restRange: entry.value.restRange,
              bottomText: entry.value.bottomText,
              onRepsTap: () => Navigator.pushNamed(
                context,
                WorkoutSessionView.routeName,
                arguments: (
                  exercise: entry.value,
                  exerciseIndex: entry.key + 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({required this.selectedDay, required this.onChanged});

  final int selectedDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Type Of Training: ',
          style: AppTextStyles.medium16(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(width: 4.w),
        DropdownButton<int>(
          value: selectedDay,
          dropdownColor: AppColors.cardBackground,
          underline: const SizedBox.shrink(),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
            size: 24.sp,
          ),
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
          items: List.generate(
            7,
            (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1}')),
          ),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }
}
