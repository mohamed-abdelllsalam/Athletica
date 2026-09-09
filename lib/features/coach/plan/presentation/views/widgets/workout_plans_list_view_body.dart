import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plan_detail_view.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Coach template library — `GET /workout/templates` + `POST /workout/templates`.
/// Visuals unchanged; hardcoded programs removed.
class WorkoutPlansListViewBody extends StatefulWidget {
  const WorkoutPlansListViewBody({super.key});

  @override
  State<WorkoutPlansListViewBody> createState() =>
      _WorkoutPlansListViewBodyState();
}

class _WorkoutPlansListViewBodyState extends State<WorkoutPlansListViewBody> {
  late final TextEditingController _searchController;
  String _query = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    'Strength',
    'Fat loss',
    'Boxing',
    'Mobility',
    'Custom',
  ];

  static const List<Color> _iconColors = [
    Color(0xFF5A0BFC),
    Color(0xFF2E8A4A),
    Color(0xFFB5541C),
    Color(0xFF1B6E6A),
    Color(0xFF8A2E4A),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isArabic() =>
      Localizations.localeOf(context).languageCode == 'ar';

  List<WorkoutTemplateEntry> _filtered(List<WorkoutTemplateEntry> items) {
    return items.where((t) {
      final matchesQuery = _query.isEmpty ||
          t.title.toLowerCase().contains(_query.toLowerCase()) ||
          t.description.toLowerCase().contains(_query.toLowerCase());
      // The workout API has no category field — every template maps to
      // 'Custom' so the existing chips keep working without fake data.
      final category = 'Custom';
      final matchesCategory =
          _selectedCategory == 'All' || category == _selectedCategory;
      return matchesCategory && matchesQuery;
    }).toList();
  }

  WorkoutProgram _toProgram(WorkoutTemplateEntry t) => WorkoutProgram(
        id: t.id,
        name: t.title,
        category: 'Custom',
        splitType: '${t.dayCount} Days Split',
        updatedAgo: _timeAgo(t.createdAt),
        clientCount: 0,
        iconAsset: 'assets/images/plan/upper_body_icon.svg',
        description: t.description,
        days: t.days
            .map(
              (d) => ProgramDay(
                dayNumber: d.dayNumber,
                name: d.title,
                durationMinutes: 60,
                exercises: d.exercises
                    .map(
                      (e) => ProgramExercise(
                        id: e.exerciseId,
                        name: e.exercise?.localizedName(_isArabic()) ??
                            e.exerciseId,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );

  String _timeAgo(DateTime? date) {
    if (date == null) return '—';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  Future<void> _createNewPlan() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _CreateTemplateDialog(),
    );
    if (result == null || !mounted) return;
    final ok = await context.read<WorkoutTemplatesCubit>().create(
          title: result.$1,
          description: result.$2,
        );
    if (!mounted) return;
    if (!ok) {
      final s = context.read<WorkoutTemplatesCubit>().state;
      if (s is WorkoutTemplatesLoaded && s.mutationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.mutationError!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'My Workout plans',
                style: AppTextStyles.semiBold15(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Your program Templates Library',
            style: AppTextStyles.meduim12(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: _SearchBar(
                  controller: _searchController,
                  hint: 'Search Templates..',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(width: 10.w),
              _CreateButton(onTap: _createNewPlan),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 36.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = cat == _selectedCategory;
              return _CategoryChip(
                label: cat,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCategory = cat),
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
        Expanded(
          child: BlocBuilder<WorkoutTemplatesCubit, WorkoutTemplatesState>(
            builder: (context, state) => switch (state) {
              WorkoutTemplatesInitial() ||
              WorkoutTemplatesLoading() =>
                const Center(child: CircularProgressIndicator()),
              WorkoutTemplatesError(:final message) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium14(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () =>
                              context.read<WorkoutTemplatesCubit>().refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              WorkoutTemplatesLoaded(:final items) => () {
                  final programs =
                      _filtered(items).map(_toProgram).toList();
                  if (programs.isEmpty) {
                    return Center(
                      child: Text(
                        'No programs found',
                        style: AppTextStyles.medium14(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<WorkoutTemplatesCubit>().refresh(),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 4.h),
                      itemCount: programs.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final program = programs[index];
                        final color =
                            _iconColors[index % _iconColors.length];
                        return _ProgramCard(
                          program: program,
                          iconColor: color,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkoutPlanDetailView(program: program),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }(),
            },
          ),
        ),
      ],
    );
  }
}

/// Owns its controllers so they are disposed with the dialog route itself —
/// never dispose a dialog's controller right after `await showDialog`,
/// the exit animation still paints its TextFields.
class _CreateTemplateDialog extends StatefulWidget {
  const _CreateTemplateDialog();

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Text(
        'Create Workout Template',
        style: AppTextStyles.semiBold14(context)
            .copyWith(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text.trim();
            final desc = _descController.text.trim();
            if (title.isEmpty || desc.isEmpty) return;
            Navigator.pop(context, (title, desc));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.medium14(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18.sp),
            SizedBox(width: 4.w),
            Text(
              'Create New Plan',
              style: AppTextStyles.meduim12(context).copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.iconColor,
    required this.onTap,
  });

  final WorkoutProgram program;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SvgPicture.asset(
                program.iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.name.isEmpty ? 'Unnamed Plan' : program.name,
                          style: AppTextStyles.semiBold14(context).copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _CategoryBadge(category: program.category),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        program.splitType,
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '  •  ',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          program.updatedAgo,
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Used by ${program.clientCount} clients',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
        'Strength' => const Color(0xFF7B4FE8),
        'Fat loss' => const Color(0xFF7B4FE8),
        'Boxing' => const Color(0xFFD4752A),
        'Mobility' => const Color(0xFF2E6DB4),
        'Custom' => const Color(0xFFB22A4A),
        'Vegan' => const Color(0xFF2E8A4A),
        _ => AppColors.primaryBlue,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        category,
        style: AppTextStyles.semiBold10(context).copyWith(color: _color),
      ),
    );
  }
}
