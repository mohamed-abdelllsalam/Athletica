import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/get_workout_templates_usecase.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignTemplateSheet extends StatefulWidget {
  const AssignTemplateSheet({super.key, required this.type});

  final AssignType type;

  @override
  State<AssignTemplateSheet> createState() => _AssignTemplateSheetState();
}

class _AssignTemplateSheetState extends State<AssignTemplateSheet> {
  String _query = '';
  bool _isLoading = true;
  String? _error;
  List<_TemplateItem> _templates = [];
  String? _selectedId;
  bool _isAssigning = false;

  bool get _isWorkout => widget.type == AssignType.workout;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isWorkout) {
        final useCase = sl<GetWorkoutTemplatesUseCase>();
        final trainerId = await TokenStorageService.instance.getTrainerId();
        if (trainerId == null) {
          setState(() {
            _error = 'Trainer ID not found';
            _isLoading = false;
          });
          return;
        }
        final result = await useCase(trainerId);
        switch (result) {
          case ApiSuccess(:final data):
            setState(() {
              _templates = data
                  .map((t) => _TemplateItem(
                        id: t.id,
                        name: t.title,
                        subtitle: t.level,
                      ))
                  .toList();
              _isLoading = false;
            });
          case ApiError(:final failure):
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
        }
      } else {
        final useCase = sl<GetNutritionTemplatesUseCase>();
        final result = await useCase(pageSize: 50);
        switch (result) {
          case ApiSuccess(:final data):
            setState(() {
              _templates = data.templates
                  .map((t) => _TemplateItem(
                        id: t.id,
                        name: t.title,
                        subtitle: t.description,
                        mealCount: t.mealCount,
                      ))
                  .toList();
              _isLoading = false;
            });
          case ApiError(:final failure):
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<_TemplateItem> get _filtered {
    if (_query.isEmpty) return _templates;
    final lower = _query.toLowerCase();
    return _templates
        .where((t) => t.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            8.h,
            20.w,
            MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              SizedBox(height: 12.h),
              _buildTitle(),
              SizedBox(height: 16.h),
              _buildSearchField(),
              SizedBox(height: 16.h),
              Expanded(child: _buildBody(scrollController)),
              SizedBox(height: 12.h),
              _buildCancelButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _isWorkout ? 'Select Workout Template' : 'Select Nutrition Template',
      style: AppTextStyles.bold20(context)
          .copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        style: AppTextStyles.medium14(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search templates...',
          hintStyle: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search,
              color: AppColors.textSecondary, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final items = _filtered;

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No templates available',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.id == _selectedId;
        return _TemplateTile(
          item: item,
          isSelected: isSelected,
          onTap: () => setState(() => _selectedId = item.id),
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: _isAssigning
            ? null
            : () {
                if (_selectedId != null) {
                  _assign();
                } else {
                  Navigator.pop(context);
                }
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color:
                _selectedId != null ? AppColors.primaryBlue : AppColors.surfaceDark,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isAssigning
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _selectedId != null ? 'Assign' : 'Cancel',
                style: AppTextStyles.semiBold15(context).copyWith(
                  color: _selectedId != null
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }

  Future<void> _assign() async {
    if (_selectedId == null || _isAssigning) return;

    setState(() => _isAssigning = true);

    final cubit = context.read<AssignedCubit>();
    if (_isWorkout) {
      await cubit.assignWorkout(_selectedId!);
    } else {
      await cubit.assignNutrition(_selectedId!);
    }

    if (!mounted) return;

    final actionState = cubit.actionState;
    if (actionState is AssignActionSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isWorkout
                ? 'Workout plan assigned!'
                : 'Nutrition plan assigned!',
          ),
        ),
      );
    } else if (actionState is AssignActionError) {
      setState(() => _isAssigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionState.message)),
      );
    }
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _TemplateItem {
  const _TemplateItem({
    required this.id,
    required this.name,
    this.subtitle,
    this.mealCount,
  });

  final String id;
  final String name;
  final String? subtitle;
  final int? mealCount;
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _TemplateItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.surfaceDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.fitness_center,
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.subtitle != null || item.mealCount != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle ??
                          '${item.mealCount} meals',
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
