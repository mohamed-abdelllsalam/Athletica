import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/entities/assigned_client.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/template_detail_cubit.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/meal_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NutritionPlanDetailViewBody extends StatefulWidget {
  const NutritionPlanDetailViewBody({
    super.key,
    required this.plan,
    this.isCreateMode = false,
  });

  final NutritionPlan plan;
  final bool isCreateMode;

  @override
  State<NutritionPlanDetailViewBody> createState() =>
      _NutritionPlanDetailViewBodyState();
}

class _NutritionPlanDetailViewBodyState
    extends State<NutritionPlanDetailViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Meal> _meals;
  final TextEditingController _noteController = TextEditingController();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late String _selectedCategory;
  bool _nameHasError = false;
  bool _descriptionHasError = false;

  static const List<String> _categories = [
    'Fat loss',
    'Muscle Gain',
    'Vegan',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _meals = List.from(widget.plan.meals);
    _nameController = TextEditingController(text: widget.plan.name);
    _nameController.addListener(() {
      if (_nameHasError && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameHasError = false);
      }
    });
    _descriptionController = TextEditingController(
      text: widget.plan.description,
    );
    _descriptionController.addListener(() {
      if (_descriptionHasError &&
          _descriptionController.text.trim().isNotEmpty) {
        setState(() => _descriptionHasError = false);
      }
    });
    _caloriesController = TextEditingController(
      text: widget.plan.calories == 0 ? '' : widget.plan.calories.toString(),
    );
    _proteinController = TextEditingController(
      text: widget.plan.proteinGrams == 0
          ? ''
          : widget.plan.proteinGrams.toString(),
    );
    _fatController = TextEditingController(
      text: widget.plan.fatGrams == 0 ? '' : widget.plan.fatGrams.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.plan.carbsGrams == 0
          ? ''
          : widget.plan.carbsGrams.toString(),
    );
    _selectedCategory = widget.plan.category.isEmpty
        ? 'Custom'
        : widget.plan.category;
  }

  String _iconForCategory(String category) => switch (category) {
    'Fat loss' => 'assets/images/plan/fatloss_icon.svg',
    'Muscle Gain' => 'assets/images/plan/muscle_gain_icon.svg',
    'Vegan' => 'assets/images/plan/vegan_icon.svg',
    _ => 'assets/images/plan/nutrition_icon.svg',
  };

  String get _currentIconAsset => widget.isCreateMode
      ? _iconForCategory(_selectedCategory)
      : widget.plan.iconAsset;

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  /// Totals derived from the current meals' ingredients.
  int get _mealsCalories => _meals.fold(0, (s, m) => s + m.calories);
  int get _mealsProtein => _meals.fold(0, (s, m) => s + m.proteinGrams);
  int get _mealsFat => _meals.fold(0, (s, m) => s + m.fatGrams);
  int get _mealsCarbs => _meals.fold(0, (s, m) => s + m.carbsGrams);

  NutritionPlan _buildPlan() {
    final name = _nameController.text.trim();
    // Manual entries win; otherwise totals are computed from the meals so
    // the saved plan never carries stale/zero numbers by accident.
    final calories =
        int.tryParse(_caloriesController.text.trim()) ?? _mealsCalories;
    final protein =
        int.tryParse(_proteinController.text.trim()) ?? _mealsProtein;
    final fat = int.tryParse(_fatController.text.trim()) ?? _mealsFat;
    final carbs = int.tryParse(_carbsController.text.trim()) ?? _mealsCarbs;
    return NutritionPlan(
      id: widget.plan.id,
      name: name,
      category: _selectedCategory,
      calories: calories,
      proteinGrams: protein,
      fatGrams: fat,
      carbsGrams: carbs,
      planDuration: widget.plan.planDuration.isEmpty
          ? '4 Week Plan'
          : widget.plan.planDuration,
      updatedAgo: 'Just created',
      clientCount: 0,
      meals: _meals,
      description: _descriptionController.text.trim(),
      iconAsset: _currentIconAsset,
    );
  }

  void _trySavePlan() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    var hasError = false;
    if (name.isEmpty) {
      setState(() => _nameHasError = true);
      hasError = true;
    }
    if (description.isEmpty) {
      // Validate before leaving the page — the backend requires a
      // description, so failing here would otherwise surface as a snackbar
      // on the previous screen after pop.
      setState(() => _descriptionHasError = true);
      hasError = true;
    }
    if (hasError) return;
    Navigator.pop(context, _buildPlan());
  }

  /// Leaving flow in create mode: Save and exit, or Discard.
  Future<void> _exitWithResolution() async {
    // Dismiss the keyboard first — otherwise it stays on top of and
    // visually hides the dialog (name field is autofocus).
    FocusScope.of(context).unfocus();
    final hasContent =
        _nameController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _caloriesController.text.trim().isNotEmpty ||
        _proteinController.text.trim().isNotEmpty ||
        _fatController.text.trim().isNotEmpty ||
        _carbsController.text.trim().isNotEmpty ||
        _meals.isNotEmpty;
    if (!hasContent) {
      Navigator.pop(context);
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Unsaved changes',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Do you want to save your changes before leaving?',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'saveExit'),
            child: Text(
              'Save and exit',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(
              'Discard',
              style:
                  AppTextStyles.medium14(context).copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'saveExit':
        // Validates name/description, then pops with the built plan.
        _trySavePlan();
      case 'discard':
        Navigator.pop(context);
    }
  }

  Future<void> _handleMealTap(Meal meal) async {
    final updatedMeal = await Navigator.push<Meal>(
      context,
      MaterialPageRoute(
        builder: (_) => MealDetailView(
          meal: meal,
          onDelete: () => _deleteMeal(meal),
          // Saved templates persist edits in place; create mode can only
          // hand the updated meal back as a route result.
          onPersist: widget.isCreateMode
              ? null
              : (m) => context.read<TemplateDetailCubit>().applyMealEdits(m),
        ),
      ),
    );
    if (updatedMeal == null) return;
    if (!widget.isCreateMode) {
      // Persisted template: push the diff to the backend, then refresh.
      if (mounted) {
        await context.read<TemplateDetailCubit>().applyMealEdits(updatedMeal);
      }
      return;
    }
    setState(() {
      final index = _meals.indexWhere((m) => m.id == meal.id);
      if (index != -1) {
        _meals[index] = updatedMeal;
      }
    });
  }

  /// Deletes a meal — locally in create mode, via
  /// `DELETE /nutrition/templates/:id/meals/:mealId` for persisted ones.
  void _deleteMeal(Meal meal) {
    if (!widget.isCreateMode) {
      context.read<TemplateDetailCubit>().deleteMeal(meal.id);
      return;
    }
    setState(() => _meals.removeWhere((m) => m.id == meal.id));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCreateMode) {
      return UnfocusOnTap(child: _buildContent(context, widget.plan));
    }
    return UnfocusOnTap(
      child: BlocConsumer<TemplateDetailCubit, TemplateDetailState>(
      listener: (context, state) {
        final message = state is TemplateDetailLoaded ? state.message : null;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: AppTextStyles.medium14(context)
                    .copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          context.read<TemplateDetailCubit>().clearMessage();
        }
      },
      builder: (context, state) {
        switch (state) {
          case TemplateDetailInitial():
          case TemplateDetailLoading():
            return AppShimmer(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(20.r),
                itemCount: 5,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (_, _) => SkeletonBox(height: 72.h, radius: 14.r),
              ),
            );
          case TemplateDetailError(:final message):
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TemplateDetailCubit>()
                        .load(widget.plan.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          case TemplateDetailLoaded(:final plan):
            return _buildContent(context, plan);
          case TemplateDetailDeleted():
            return const SizedBox.shrink();
        }
      },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NutritionPlan displayPlan) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!widget.isCreateMode) {
          Navigator.pop(
            context,
            context.read<TemplateDetailCubit>().hasChanges,
          );
          return;
        }
        await _exitWithResolution();
      },
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GestureDetector(
              onTap: () async {
                if (!widget.isCreateMode) {
                  Navigator.pop(context, context.read<TemplateDetailCubit>().hasChanges);
                  return;
                }
                await _exitWithResolution();
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Plan header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SvgPicture.asset(
                    _currentIconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isCreateMode) ...[
                        Text(
                          'Plan Name',
                          style: AppTextStyles.meduim12(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 4.h),
                        _EditableNameField(
                          controller: _nameController,
                          hasError: _nameHasError,
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayPlan.name,
                                style: AppTextStyles.bold24(context).copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () =>
                                  _showEditMetaSheet(context, displayPlan),
                              child: Container(
                                width: 32.r,
                                height: 32.r,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.primaryBlue,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => _confirmDeleteTemplate(context),
                              child: Container(
                                width: 32.r,
                                height: 32.r,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDark,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: const Color(0xFFFF5252),
                                  size: 16.sp,
                                ),
                              ),
                            ),
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
                            // Create mode: always reflect the live meal
                            // totals; Daily targets inputs stay as manual
                            // targets saved with the plan.
                            '${widget.isCreateMode ? _mealsCalories : displayPlan.calories} calories',
                            style: AppTextStyles.meduim12(
                              context,
                            ).copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 8.w),
                          if (widget.isCreateMode)
                            _CategorySelector(
                              selected: _selectedCategory,
                              categories: _categories,
                              onChanged: (v) =>
                                  setState(() => _selectedCategory = v),
                            )
                          else
                            _CategoryBadge(category: displayPlan.category),
                        ],
                      ),
                      if (!widget.isCreateMode) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.textSecondary,
                              size: 12.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              displayPlan.updatedAgo,
                              style: AppTextStyles.meduim12(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
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
                              'Used by ${displayPlan.clientCount} clients',
                              style: AppTextStyles.meduim12(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: widget.isCreateMode
                  ? ElevatedButton(
                      onPressed: _trySavePlan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Save Plan',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _showAssignSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      label: Text(
                        'Assign to client',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 2,
              labelStyle: AppTextStyles.semiBold14(context),
              unselectedLabelStyle: AppTextStyles.medium14(context),
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Note'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  plan: displayPlan,
                  meals: widget.isCreateMode
                      ? _meals
                      : displayPlan.meals,
                  isCreateMode: widget.isCreateMode,
                  descriptionController: _descriptionController,
                  descriptionHasError: _descriptionHasError,
                  caloriesController: _caloriesController,
                  proteinController: _proteinController,
                  fatController: _fatController,
                  carbsController: _carbsController,
                  onMacrosChanged: () => setState(() {}),
                  onAddMeal: widget.isCreateMode
                      ? () => setState(
                          () => _meals.add(
                                Meal(
                                  id:
                                      'm${DateTime.now().millisecondsSinceEpoch}',
                                  type: 'Meal ${_meals.length + 1}',
                                  name: 'New Meal',
                                  calories: 0,
                                  proteinGrams: 0,
                                  fatGrams: 0,
                                  carbsGrams: 0,
                                  ingredients: [],
                                ),
                              ),
                        )
                      : () => context.read<TemplateDetailCubit>().addMeal(),
                  onReorder: widget.isCreateMode
                      ? (oldIndex, newIndex) => setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final meal = _meals.removeAt(oldIndex);
                            _meals.insert(newIndex, meal);
                          })
                      : (oldIndex, newIndex) => context
                          .read<TemplateDetailCubit>()
                          .reorderMeals(oldIndex, newIndex),
                  onMealTap: (meal) {
                    _handleMealTap(meal);
                  },
                ),
                _NoteTab(controller: _noteController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog, then deletes the template and pops the
  /// detail screen so the list can refresh.
  Future<void> _confirmDeleteTemplate(BuildContext context) async {
    final plan = context.read<TemplateDetailCubit>().state is TemplateDetailLoaded
        ? (context.read<TemplateDetailCubit>().state as TemplateDetailLoaded).plan
        : null;
    final clientCount = plan?.clientCount ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete template?',
          style: AppTextStyles.bold20(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          clientCount > 0
              ? 'This template is assigned to $clientCount client(s). '
                  'You must remove all assigned plans first before deleting.'
              : 'This will permanently delete this template and cannot be undone.',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          if (clientCount == 0)
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final deleted =
          await context.read<TemplateDetailCubit>().deleteTemplate();
      if (deleted && context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Opens the template meta editor (name/description) for persisted
  /// templates; create mode already edits these inline.
  void _showEditMetaSheet(BuildContext context, NutritionPlan plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _EditTemplateMetaSheet(
        initialName: plan.name,
        initialDescription: plan.description,
        onSave: ({required title, required description}) => context
            .read<TemplateDetailCubit>()
            .updateTemplateMeta(title: title, description: description),
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    final state = context.read<TemplateDetailCubit>().state;
    if (state is! TemplateDetailLoaded) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      // Modal routes do not inherit providers from the page, so the sheet
      // must own its AssignPlanCubit.
      builder: (_) => BlocProvider(
        create: (_) => sl<AssignPlanCubit>()..loadClients(),
        child: _AssignToClientSheet(plan: state.plan),
      ),
    );
  }
}

// ── Editable name field (create mode) ────────────────────────────────────────

class _EditableNameField extends StatelessWidget {
  const _EditableNameField({required this.controller, required this.hasError});

  final TextEditingController controller;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: AppTextStyles.bold24(
        context,
      ).copyWith(color: AppColors.textPrimary, fontSize: 20.sp),
      decoration: InputDecoration(
        hintText: 'Plan name',
        hintStyle: AppTextStyles.bold24(
          context,
        ).copyWith(color: AppColors.textSecondary, fontSize: 20.sp),
        errorText: hasError ? 'Required' : null,
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Category selector pill (create mode) ─────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.categories,
    required this.onChanged,
  });

  final String selected;
  final List<String> categories;
  final ValueChanged<String> onChanged;

  Color get _color => switch (selected) {
    'Fat loss' => const Color(0xFF7B4FE8),
    'Muscle Gain' => const Color(0xFF3D6BC2),
    'Vegan' => const Color(0xFF2E8A4A),
    _ => const Color(0xFFB22A4A),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pick = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (_) =>
              _CategoryPickerSheet(categories: categories, selected: selected),
        );
        if (pick != null) onChanged(pick);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: AppTextStyles.semiBold10(context).copyWith(color: _color),
            ),
            SizedBox(width: 3.w),
            Icon(Icons.arrow_drop_down, color: _color, size: 14.sp),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selected,
  });

  final List<String> categories;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
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
            'Select Category',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 14.h),
          ...categories.map(
            (cat) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                cat,
                style: AppTextStyles.medium14(context).copyWith(
                  color: cat == selected
                      ? AppColors.buttonColor
                      : AppColors.textPrimary,
                ),
              ),
              trailing: cat == selected
                  ? Icon(Icons.check, color: AppColors.buttonColor, size: 18.sp)
                  : null,
              onTap: () => Navigator.pop(context, cat),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.plan,
    required this.meals,
    required this.isCreateMode,
    required this.descriptionController,
    required this.descriptionHasError,
    required this.caloriesController,
    required this.proteinController,
    required this.fatController,
    required this.carbsController,
    required this.onMacrosChanged,
    required this.onAddMeal,
    required this.onReorder,
    required this.onMealTap,
  });

  final NutritionPlan plan;
  final List<Meal> meals;
  final bool isCreateMode;
  final TextEditingController descriptionController;
  final bool descriptionHasError;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController fatController;
  final TextEditingController carbsController;
  final VoidCallback onMacrosChanged;
  final VoidCallback onAddMeal;

  /// Drag & drop reorder: local list in create mode, backend
  /// `PUT .../meals/reorder` for persisted templates.
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<Meal> onMealTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
        ),
        SizedBox(height: 8.h),
        if (isCreateMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10.r),
                  border: descriptionHasError
                      ? Border.all(color: Colors.redAccent)
                      : null,
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  decoration: InputDecoration(
                    hintText: 'Add a program description…',
                    hintStyle: AppTextStyles.medium14(
                      context,
                    ).copyWith(
                      color: descriptionHasError
                          ? Colors.redAccent
                          : AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (descriptionHasError) ...[
                SizedBox(height: 6.h),
                Text(
                  'Description is required',
                  style: AppTextStyles.meduim12(context)
                      .copyWith(color: Colors.redAccent),
                ),
              ],
            ],
          )
        else
          Text(
            plan.description,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
        SizedBox(height: 16.h),
        // Daily targets card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily targets',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (isCreateMode) ...[
                    _MacroInput(
                      controller: caloriesController,
                      label: 'Calories',
                      color: AppColors.primaryBlue,
                      onChanged: (_) => onMacrosChanged(),
                    ),
                    _MacroInput(
                      controller: proteinController,
                      label: 'Protein',
                      color: const Color(0xFF4CAF50),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                    _MacroInput(
                      controller: fatController,
                      label: 'Fat',
                      color: const Color(0xFFFFB300),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                    _MacroInput(
                      controller: carbsController,
                      label: 'Carbs',
                      color: const Color(0xFF42A5F5),
                      onChanged: (_) => onMacrosChanged(),
                      suffix: 'g',
                    ),
                  ] else ...[
                    _MacroStat(
                      value: '${plan.calories}',
                      label: 'Calories',
                      color: AppColors.primaryBlue,
                    ),
                    _MacroStat(
                      value: '${plan.proteinGrams}g',
                      label: 'Protein',
                      color: const Color(0xFF4CAF50),
                    ),
                    _MacroStat(
                      value: '${plan.fatGrams}g',
                      label: 'Fat',
                      color: const Color(0xFFFFB300),
                    ),
                    _MacroStat(
                      value: '${plan.carbsGrams}g',
                      label: 'Carbs',
                      color: const Color(0xFF42A5F5),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meal Plan',
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onAddMeal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.primaryBlue, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Meal',
                      style: AppTextStyles.meduim12(
                        context,
                      ).copyWith(color: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (meals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'No meals yet',
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            buildDefaultDragHandles: false,
            onReorder: onReorder,
            proxyDecorator: (child, index, animation) => AnimatedBuilder(
              animation: animation,
              builder: (_, child) => Material(
                color: Colors.transparent,
                elevation: 6 * animation.value,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(14.r),
                child: child,
              ),
              child: child,
            ),
            children: [
              for (var i = 0; i < meals.length; i++)
                Container(
                  key: ValueKey(meals[i].id),
                  margin: EdgeInsets.only(bottom: 12.h),
                  // Long-press anywhere on the card also starts a drag;
                  // the ≡ handle starts one immediately.
                  child: ReorderableDelayedDragStartListener(
                    index: i,
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Icon(
                              Icons.drag_handle,
                              color: AppColors.textSecondary,
                              size: 22.sp,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _MealCard(
                            meal: meals[i],
                            onTap: () => onMealTap(meals[i]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bold24(
            context,
          ).copyWith(color: color, fontSize: 18.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MacroInput extends StatelessWidget {
  const _MacroInput({
    required this.controller,
    required this.label,
    required this.color,
    required this.onChanged,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final ValueChanged<String> onChanged;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 56.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: onChanged,
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: color, fontSize: 18.sp),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppTextStyles.bold24(
                context,
              ).copyWith(color: color.withValues(alpha: 0.4), fontSize: 18.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          suffix == null ? label : '$label ($suffix)',
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});

  final Meal meal;
  final VoidCallback onTap;

  static IconData _iconForType(String type) => switch (type) {
    'Breakfast' => Icons.wb_sunny_outlined,
    'Lunch' => Icons.restaurant_outlined,
    'Snack' => Icons.cake_outlined,
    'Dinner' => Icons.nightlight_outlined,
    _ => Icons.local_cafe_outlined,
  };

  static Color _bgColorForType(String type) => switch (type) {
    'Breakfast' => const Color(0xFF2C6E3A),
    'Lunch' => const Color(0xFF1C5C2A),
    'Snack' => const Color(0xFF3D2A7A),
    'Dinner' => const Color(0xFF2A1C5A),
    _ => const Color(0xFF1C2A5A),
  };

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
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: _bgColorForType(meal.type),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _iconForType(meal.type),
                color: Colors.white,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: AppTextStyles.semiBold14(
                      context,
                    ).copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${meal.calories} CAL . ${meal.proteinGrams}G Protein',
                    style: AppTextStyles.meduim12(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Tab ─────────────────────────────────────────────────────────────────

class _NoteTab extends StatelessWidget {
  const _NoteTab({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write Note',
            style: AppTextStyles.semiBold14(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type Your Note !',
                  hintStyle: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Submit',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
    'Fat loss' => const Color(0xFF7B4FE8),
    'Muscle Gain' => const Color(0xFF3D6BC2),
    'Vegan' => const Color(0xFF2E8A4A),
    'Custom' => const Color(0xFFB22A4A),
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

// ── Assign to client bottom sheet ────────────────────────────────────────────

class _AssignToClientSheet extends StatefulWidget {
  const _AssignToClientSheet({required this.plan});

  final NutritionPlan plan;

  @override
  State<_AssignToClientSheet> createState() => _AssignToClientSheetState();
}

class _AssignToClientSheetState extends State<_AssignToClientSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedClientId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submit(AssignPlanState state) {
    if (state is AssignPlanAssigning) return;
    final clients = switch (state) {
      AssignPlanClientsLoaded(:final clients) => clients,
      AssignPlanError(:final clients) => clients,
      _ => <AssignedClient>[],
    };
    final selectedId = _selectedClientId;
    if (selectedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a client',
            style:
                AppTextStyles.medium14(context).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.buttonColor,
        ),
      );
      return;
    }
    final selected =
        clients.where((c) => c.relationId == selectedId).firstOrNull;
    if (selected == null) return;
    context.read<AssignPlanCubit>().assign(
          templateId: widget.plan.id,
          coachClientId: selected.relationId,
          title: widget.plan.name.isEmpty ? 'Nutrition Plan' : widget.plan.name,
          description: widget.plan.description.isEmpty
              ? 'Nutrition Plan'
              : widget.plan.description,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignPlanCubit, AssignPlanState>(
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        switch (state) {
          case AssignPlanSuccess():
            Navigator.pop(context);
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Plan assigned successfully',
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
          case AssignPlanError(:final message):
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          default:
            break;
        }
      },
      builder: (context, state) {
        Widget body;
        switch (state) {
          case AssignPlanInitial():
          case AssignPlanClientsLoading():
            body = SizedBox(
              height: 200.h,
              child: AppShimmer(
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++) ...[
                      if (i > 0) SizedBox(width: 16.w),
                      SkeletonBox(width: 56.w, height: 72.h, radius: 28.r),
                    ],
                  ],
                ),
              ),
            );
          case AssignPlanClientsError(:final message):
            body = SizedBox(
              height: 200.h,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AssignPlanCubit>().loadClients(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.medium14(context)
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          default:
            body = _buildClientPicker(context, state);
        }

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
                body,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientPicker(BuildContext context, AssignPlanState state) {
    final clients = switch (state) {
      AssignPlanClientsLoaded(:final clients) => clients,
      AssignPlanAssigning(:final clients) => clients,
      AssignPlanError(:final clients) => clients,
      _ => <AssignedClient>[],
    };
    final isAssigning = state is AssignPlanAssigning;
    final query = _searchController.text.toLowerCase();
    final filtered = clients
        .where((c) => query.isEmpty || c.name.toLowerCase().contains(query))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 80.h,
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No assigned clients found',
                    style: AppTextStyles.meduim12(context)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => SizedBox(width: 16.w),
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    final isSelected = _selectedClientId == client.relationId;
                    final name = client.name;
                    return GestureDetector(
                      onTap: () => setState(
                          () => _selectedClientId = client.relationId),
                      child: Column(
                        children: [
                          Container(
                            width: 48.r,
                            height: 48.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceDark,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 26.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          SizedBox(
                            width: 56.w,
                            child: Text(
                              name.split(' ').first,
                              style: AppTextStyles.meduim11(
                                context,
                              ).copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: isAssigning ? null : () => _submit(state),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: isAssigning
                ? SizedBox(
                    height: 22.h,
                    width: 22.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Submit',
                    style: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

// ── Template meta editor (view mode) ─────────────────────────────────────────

/// Edit sheet for a persisted template's name/description
/// (`PUT /nutrition/templates/:id`). Returns `null` from [onSave] on success;
/// a string is surfaced inline as the failure reason.
class _EditTemplateMetaSheet extends StatefulWidget {
  const _EditTemplateMetaSheet({
    required this.initialName,
    required this.initialDescription,
    required this.onSave,
  });

  final String initialName;
  final String initialDescription;
  final Future<String?> Function({required String title, required String description})
      onSave;

  @override
  State<_EditTemplateMetaSheet> createState() => _EditTemplateMetaSheetState();
}

class _EditTemplateMetaSheetState extends State<_EditTemplateMetaSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
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
              style: AppTextStyles.semiBold14(context)
                  .copyWith(color: AppColors.textPrimary, fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Plan Name',
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
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
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Plan name',
                  hintStyle: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Description',
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
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
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Add a program description…',
                  hintStyle: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textTertiary),
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
                style: AppTextStyles.meduim12(context)
                    .copyWith(color: Colors.redAccent),
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
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: Colors.white),
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
