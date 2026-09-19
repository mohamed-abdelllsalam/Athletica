import 'meal_note_tab.dart';
import 'meal_detail_dialogs.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/food_search_view.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/meal_detail_sections.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/meal_detail_header.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/meal_grams_edit_sheet.dart';
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

  /// Single source of truth for the meal note, shared by the "Meal Notes"
  /// field in the details tab and the "Note" tab so edits in either place
  /// mark the meal dirty and are included in the saved meal.
  final TextEditingController _mealNoteController = TextEditingController();
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
    _nameController.dispose();
    // _nameController has a listener; TextEditingController.dispose()
    // unregisters it — no explicit removeListener needed for disposal.
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
      builder: (_) => CoachMealUnsavedChangesDialog(
        titleStyle: AppTextStyles.semiBold14(context),
        bodyStyle: AppTextStyles.medium14(context),
        onSave: () => Navigator.pop(context, 'save'),
        onSaveAndExit: () => Navigator.pop(context, 'saveExit'),
        onDiscard: () => Navigator.pop(context, 'discard'),
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
      builder: (_) => CoachMealDeleteDialog(
        titleStyle: AppTextStyles.semiBold14(context),
        bodyStyle: AppTextStyles.medium14(context),
        onCancel: () => Navigator.pop(context, false),
        onDelete: () => Navigator.pop(context, true),
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

  /// "Submit" from the Note tab: same contract as "Save Changes" in the
  /// details tab — validates the meal name and exits with the built meal
  /// (which carries the shared note controller text).
  void _submitNoteTab() {
    if (_nameController.text.trim().isEmpty) {
      // The name field lives in the header; flag the error and show the
      // details tab so the coach can fix it.
      setState(() {
        _nameHasError = true;
        _tabController.index = 0;
      });
      return;
    }
    Navigator.pop(context, _buildMeal());
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
      builder: (_) => MealGramsEditSheet(
        ingredientName: ingredient.name,
        currentGrams: currentGrams,
      ),
    );
    if (!mounted) return;
    if (newGrams == null || newGrams <= 0) return;
    // A zero/negative source serving (e.g. legacy "0g") would scale through
    // divide-by-zero into Infinity/NaN macros — keep the previous valid
    // state instead of producing invalid numbers.
    if (currentGrams <= 0) return;
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
    if (!mounted) return;
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
            name: item.displayName,
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
          MealDetailHeader(
            nameController: _nameController,
            nameHasError: _nameHasError,
            showDelete: widget.onDelete != null,
            totalCalories: _totalCalories,
            totalProtein: _totalProtein,
            totalCarbs: _totalCarbs,
            totalFat: _totalFat,
            onExit: _exitWithResolution,
            onDelete: _confirmDelete,
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
                MealDetailsTab(
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
                MealNoteTab(
                  controller: _mealNoteController,
                  onSubmit: _submitNoteTab,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
