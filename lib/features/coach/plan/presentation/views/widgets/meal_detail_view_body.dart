import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/food_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealDetailViewBody extends StatefulWidget {
  const MealDetailViewBody({
    super.key,
    required this.meal,
    this.onDelete,
    this.onPersist,
  });

  final Meal meal;

  /// When provided, a delete action is shown in the header.
  final VoidCallback? onDelete;

  /// Persists edits without leaving the screen (saved templates only).
  /// When null, saving always exits with the updated meal as route result.
  final Future<void> Function(Meal meal)? onPersist;

  @override
  State<MealDetailViewBody> createState() => _MealDetailViewBodyState();
}

class _MealDetailViewBodyState extends State<MealDetailViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Ingredient> _ingredients;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealNoteController = TextEditingController();
  final TextEditingController _noteTabController = TextEditingController();
  late TextEditingController _nameController;
  bool _nameHasError = false;
  String _query = '';

  // Baseline snapshot used to detect unsaved edits.
  late String _initialName;
  late String _initialNotes;
  late String _initialIngredientsSignature;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ingredients = List.from(widget.meal.ingredients);
    _nameController = TextEditingController(text: widget.meal.name);
    _initialName = widget.meal.name.trim();
    _initialNotes = (widget.meal.notes ?? '').trim();
    _initialIngredientsSignature = _ingredientsSignature;
    _nameController.addListener(() {
      if (_nameHasError && _nameController.text.trim().isNotEmpty) {
        setState(() => _nameHasError = false);
      }
    });
    // Seed the meal-notes field with the persisted note (if any).
    _mealNoteController.text = widget.meal.notes ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _mealNoteController.dispose();
    _noteTabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String get _ingredientsSignature =>
      _ingredients.map((i) => '${i.id}:${i.serving}').join('|');

  bool get _isDirty =>
      _nameController.text.trim() != _initialName ||
      _mealNoteController.text.trim() != _initialNotes ||
      _ingredientsSignature != _initialIngredientsSignature;

  bool _validateName() {
    if (_nameController.text.trim().isNotEmpty) return true;
    setState(() => _nameHasError = true);
    return false;
  }

  /// Leaving flow for unsaved edits: Save (stay), Save and exit, Discard.
  Future<void> _exitWithResolution() async {
    FocusScope.of(context).unfocus();
    if (!_isDirty) {
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
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(
              'Save',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.primaryBlue),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'saveExit'),
            child: Text(
              'Save and exit',
              style:
                  AppTextStyles.medium14(context).copyWith(color: Colors.white),
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
      case 'discard':
        Navigator.pop(context);
      case 'saveExit':
        if (_validateName()) Navigator.pop(context, _buildMeal());
      case 'save':
        if (!_validateName()) return;
        final meal = _buildMeal();
        final persist = widget.onPersist;
        if (persist == null) {
          // No in-place persistence available — saving exits.
          if (mounted) Navigator.pop(context, meal);
          return;
        }
        await persist(meal);
        if (!mounted) return;
        setState(() {
          _initialName = meal.name.trim();
          _initialNotes = (meal.notes ?? '').trim();
          _initialIngredientsSignature = _ingredientsSignature;
        });
    }
  }

  Future<void> _confirmDelete() async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Delete meal?',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This removes the meal and all of its foods.',
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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style:
                  AppTextStyles.medium14(context).copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.onDelete?.call();
    Navigator.pop(context);
  }

  List<Ingredient> get _filtered {
    if (_query.isEmpty) return _ingredients;
    return _ingredients
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Meal _buildMeal() {
    final name = _nameController.text.trim();
    final notes = _mealNoteController.text.trim();
    // Totals are recomputed from the current ingredients so the saved meal
    // always carries up-to-date calories and macros.
    return Meal(
      id: widget.meal.id,
      type: widget.meal.type,
      name: name.isEmpty ? widget.meal.name : name,
      calories: _totalCalories,
      proteinGrams: _totalProtein,
      fatGrams: _totalFat,
      carbsGrams: _totalCarbs,
      ingredients: List<Ingredient>.from(_ingredients),
      order: widget.meal.order,
      notes: notes.isEmpty ? null : notes,
    );
  }

  int get _totalCalories => _ingredients.fold(0, (sum, i) => sum + i.calories);
  int get _totalProtein =>
      _ingredients.fold(0, (sum, i) => sum + i.proteinGrams);
  int get _totalFat => _ingredients.fold(0, (sum, i) => sum + i.fatGrams);
  int get _totalCarbs => _ingredients.fold(0, (sum, i) => sum + i.carbsGrams);

  void _removeIngredient(Ingredient ingredient) {
    setState(() => _ingredients.removeWhere((i) => i.id == ingredient.id));
  }

  Future<void> _editIngredientGrams(Ingredient ingredient) async {
    final currentGrams = _parseGrams(ingredient.serving);
    final newGrams = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _GramsEditSheet(
        ingredientName: ingredient.name,
        currentGrams: currentGrams,
      ),
    );
    if (newGrams == null || newGrams <= 0) return;
    final ratio = newGrams / currentGrams;
    final updated = Ingredient(
      id: ingredient.id,
      foodId: ingredient.foodId,
      relationId: ingredient.relationId,
      name: ingredient.name,
      emoji: ingredient.emoji,
      serving: '${newGrams}g',
      calories: (ingredient.calories * ratio).round(),
      proteinGrams: (ingredient.proteinGrams * ratio).round(),
      carbsGrams: (ingredient.carbsGrams * ratio).round(),
      fatGrams: (ingredient.fatGrams * ratio).round(),
    );
    setState(() {
      final index = _ingredients.indexWhere((i) => i.id == ingredient.id);
      if (index != -1) _ingredients[index] = updated;
    });
  }

  int _parseGrams(String serving) {
    final gMatch = RegExp(r'^(\d+)g$').firstMatch(serving.trim());
    if (gMatch != null) return int.parse(gMatch.group(1)!);
    final parenMatch = RegExp(r'\((\d+)\)').firstMatch(serving);
    if (parenMatch != null) return int.parse(parenMatch.group(1)!);
    final numMatch = RegExp(r'(\d+)').firstMatch(serving);
    if (numMatch != null) return int.parse(numMatch.group(1)!);
    return 100;
  }

  Set<String> get _existingFoodIds =>
      _ingredients.map((i) => i.foodId).whereType<String>().toSet();

  Future<void> _addIngredients() async {
    final result = await Navigator.push<List<FoodItem>>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchView(existingFoodIds: _existingFoodIds),
      ),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      var stamp = DateTime.now().millisecondsSinceEpoch;
      for (final item in result) {
        // Defensive: never duplicate a catalog food already in this meal.
        if (_existingFoodIds.contains(item.id)) continue;
        _ingredients.add(
          Ingredient(
            id: 'ing_${stamp}_${item.id}',
            foodId: item.id,
            name: item.name,
            emoji: item.emoji,
            serving: item.serving,
            calories: item.calories,
            proteinGrams: item.proteinGrams,
            carbsGrams: item.carbsGrams,
            fatGrams: item.fatGrams,
          ),
        );
        stamp += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _exitWithResolution();
      },
      child: Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              GestureDetector(
                onTap: _exitWithResolution,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 20.sp,
                ),
              ),
              const Spacer(),
              if (widget.onDelete != null)
                GestureDetector(
                  onTap: _confirmDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 22.sp,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: AppTextStyles.bold24(context).copyWith(
              color: AppColors.textPrimary,
              fontSize: 22.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Meal name',
              hintStyle: AppTextStyles.bold24(context).copyWith(
                color: AppColors.textSecondary,
                fontSize: 22.sp,
              ),
              errorText: _nameHasError ? 'Meal name is required' : null,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔥', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                '$_totalCalories Calories',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(width: 16.w),
              Container(width: 1, height: 16.h, color: AppColors.surfaceDark),
              SizedBox(width: 16.w),
              Text('🎯', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 6.w),
              Text(
                'p:${_totalProtein}g . c:${_totalCarbs}g . f:${_totalFat}g',
                style: AppTextStyles.meduim12(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
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
              Tab(text: 'Meal Details'),
              Tab(text: 'Note'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MealDetailsTab(
                searchController: _searchController,
                mealNoteController: _mealNoteController,
                ingredients: _filtered,
                query: _query,
                onQueryChanged: (v) => setState(() => _query = v),
                onRemove: _removeIngredient,
                onEditGrams: _editIngredientGrams,
                onAddIngredients: _addIngredients,
                totalCalories: _totalCalories,
                totalProtein: _totalProtein,
                totalFat: _totalFat,
                totalCarbs: _totalCarbs,
                onSave: () {
                  // Meal name is required — block saving an unnamed meal.
                  if (_nameController.text.trim().isEmpty) {
                    setState(() => _nameHasError = true);
                    return;
                  }
                  Navigator.pop(context, _buildMeal());
                },
              ),
              _NoteTab(controller: _noteTabController),
            ],
          ),
        ),
      ],
      ),
    );
  }
}

// ── Meal Details Tab ──────────────────────────────────────────────────────────

class _MealDetailsTab extends StatelessWidget {
  const _MealDetailsTab({
    required this.searchController,
    required this.mealNoteController,
    required this.ingredients,
    required this.query,
    required this.onQueryChanged,
    required this.onRemove,
    required this.onEditGrams,
    required this.onAddIngredients,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    required this.onSave,
  });

  final TextEditingController searchController;
  final TextEditingController mealNoteController;
  final List<Ingredient> ingredients;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Ingredient> onRemove;
  final ValueChanged<Ingredient> onEditGrams;
  final VoidCallback onAddIngredients;
  final int totalCalories;
  final int totalProtein;
  final int totalFat;
  final int totalCarbs;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      children: [
        Text(
          'Ingredients',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onQueryChanged,
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
            ),
            SizedBox(width: 10.w),
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: IconButton(
                onPressed: onAddIngredients,
                icon: Icon(
                  Icons.add,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (ingredients.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'No ingredients added',
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...ingredients.map(
            (ingredient) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _IngredientCard(
                ingredient: ingredient,
                onRemove: () => onRemove(ingredient),
                onEditGrams: () => onEditGrams(ingredient),
              ),
            ),
          ),
        SizedBox(height: 8.h),
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
                'Nutrition Summary',
                style: AppTextStyles.semiBold14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroStat(
                    value: '$totalCalories',
                    label: 'Calories',
                    color: AppColors.primaryBlue,
                  ),
                  _MacroStat(
                    value: '${totalProtein}g',
                    label: 'Protein',
                    color: const Color(0xFF4CAF50),
                  ),
                  _MacroStat(
                    value: '${totalFat}g',
                    label: 'Fat',
                    color: const Color(0xFFFFB300),
                  ),
                  _MacroStat(
                    value: '${totalCarbs}g',
                    label: 'Carbs',
                    color: const Color(0xFF42A5F5),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Meal Notes (Optional)',
          style: AppTextStyles.semiBold14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: mealNoteController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: AppTextStyles.medium14(
              context,
            ).copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add notes about this meal ..',
              hintStyle: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Save Changes',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
    required this.ingredient,
    required this.onRemove,
    required this.onEditGrams,
  });

  final Ingredient ingredient;
  final VoidCallback onRemove;
  final VoidCallback onEditGrams;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(ingredient.emoji, style: TextStyle(fontSize: 28.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      '${ingredient.calories} Cal',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEditGrams,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ingredient.serving,
                              style: AppTextStyles.meduim11(context)
                                  .copyWith(color: AppColors.primaryBlue),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                              size: 10.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'P:${ingredient.proteinGrams}G  C:${ingredient.carbsGrams}g  F:${ingredient.fatGrams}g',
                      style: AppTextStyles.meduim11(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
          ),
        ],
      ),
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

// ── Grams Edit Sheet ──────────────────────────────────────────────────────────

class _GramsEditSheet extends StatefulWidget {
  const _GramsEditSheet({
    required this.ingredientName,
    required this.currentGrams,
  });

  final String ingredientName;
  final int currentGrams;

  @override
  State<_GramsEditSheet> createState() => _GramsEditSheetState();
}

class _GramsEditSheetState extends State<_GramsEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGrams.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value <= 0) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              widget.ingredientName,
              style: AppTextStyles.semiBold15(context)
                  .copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              'Edit serving size in grams',
              style: AppTextStyles.meduim12(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bold24(context).copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                      ),
                      onSubmitted: (_) => _confirm(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14.h),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Text(
                      'g',
                      style: AppTextStyles.semiBold14(context)
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Confirm',
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Note Tab ──────────────────────────────────────────────────────────────────

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
