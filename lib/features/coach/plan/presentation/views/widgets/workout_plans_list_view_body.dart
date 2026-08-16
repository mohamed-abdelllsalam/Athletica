import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_plan_detail_view.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/workout_templates_list_cubit.dart';
import 'package:athletica/features/coach/workout_templates/presentation/cubits/workout_templates_list_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlansListViewBody extends StatefulWidget {
  const WorkoutPlansListViewBody({super.key});

  @override
  State<WorkoutPlansListViewBody> createState() =>
      _WorkoutPlansListViewBodyState();
}

class _WorkoutPlansListViewBodyState extends State<WorkoutPlansListViewBody> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';
  final List<WorkoutProgram> _extraPrograms = [];
  List<WorkoutProgram> _apiPrograms = [];
  bool _loading = false;

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
    context.read<WorkoutTemplatesListCubit>().loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutProgram> get _filtered {
    final programs = [..._apiPrograms, ..._extraPrograms];
    return programs.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _createNewPlan() async {
    final program = WorkoutProgram(
      id: 'wp_${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      category: 'Custom',
      splitType: '0 Days Split',
      updatedAgo: 'Just created',
      clientCount: 0,
      iconAsset: 'assets/images/plan/upper_body_icon.svg',
      description: '',
      days: [],
    );
    final result = await Navigator.push<WorkoutProgram>(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPlanDetailView(
          program: program,
          isCreateMode: true,
        ),
      ),
    );
    if (result != null) {
      setState(() => _extraPrograms.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final programs = _filtered;
    return BlocListener<WorkoutTemplatesListCubit, WorkoutTemplatesListState>(
      listener: (context, state) {
        switch (state) {
          case WorkoutTemplatesListLoading():
            setState(() => _loading = true);
          case WorkoutTemplatesListLoaded(:final programs):
            setState(() {
              _apiPrograms = programs;
              _loading = false;
            });
          case WorkoutTemplatesListError():
            setState(() => _loading = false);
          case WorkoutTemplatesListInitial():
            break;
        }
      },
      child: Column(
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : programs.isEmpty
                  ? Center(
                      child: Text(
                        'No programs found',
                        style: AppTextStyles.medium14(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 4.h),
                  itemCount: programs.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    final color = _iconColors[index % _iconColors.length];
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
        ),
      ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
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
