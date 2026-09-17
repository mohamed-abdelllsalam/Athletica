import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/widgets/app_shimmer.dart';
import 'package:athletica/core/widgets/unfocus_on_tap.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/template_detail_cubit.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/meal_detail_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_detail_sections.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_header_section.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_note_tab.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_assign_client_sheet.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/nutrition_plan_edit_meta_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(
              'Discard',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.red),
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
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: Colors.white),
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
                  itemBuilder: (_, _) =>
                      SkeletonBox(height: 72.h, radius: 14.r),
                ),
              );
            case TemplateDetailError(:final message):
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.medium14(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<TemplateDetailCubit>().load(
                        widget.plan.id,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: Text(
                        'Retry',
                        style: AppTextStyles.medium14(
                          context,
                        ).copyWith(color: Colors.white),
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
                  Navigator.pop(
                    context,
                    context.read<TemplateDetailCubit>().hasChanges,
                  );
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
          NutritionPlanHeader(
            plan: displayPlan,
            isCreateMode: widget.isCreateMode,
            iconAsset: _currentIconAsset,
            nameController: _nameController,
            nameHasError: _nameHasError,
            calories: widget.isCreateMode
                ? _mealsCalories
                : displayPlan.calories,
            selectedCategory: _selectedCategory,
            categories: _categories,
            onCategoryChanged: (value) =>
                setState(() => _selectedCategory = value),
            onEdit: () => _showEditMetaSheet(context, displayPlan),
            onDelete: () => _confirmDeleteTemplate(context),
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
                NutritionPlanOverviewTab(
                  plan: displayPlan,
                  meals: widget.isCreateMode ? _meals : displayPlan.meals,
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
                              id: 'm${DateTime.now().millisecondsSinceEpoch}',
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
                NutritionPlanNoteTab(controller: _noteController),
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
    final plan =
        context.read<TemplateDetailCubit>().state is TemplateDetailLoaded
        ? (context.read<TemplateDetailCubit>().state as TemplateDetailLoaded)
              .plan
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
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          clientCount > 0
              ? 'This template is assigned to $clientCount client(s). '
                    'You must remove all assigned plans first before deleting.'
              : 'This will permanently delete this template and cannot be undone.',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
      final deleted = await context
          .read<TemplateDetailCubit>()
          .deleteTemplate();
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
      builder: (_) => NutritionPlanEditMetaSheet(
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
        child: NutritionPlanAssignClientSheet(plan: state.plan),
      ),
    );
  }
}

// ── Editable name field (create mode) ────────────────────────────────────────
