import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/food_item.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/food_search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MealDetailViewBody extends StatefulWidget {
  const MealDetailViewBody({super.key, required this.meal});

  final Meal meal;

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
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ingredients = List.from(widget.meal.ingredients);
    _nameController = TextEditingController(text: widget.meal.name);
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

  List<Ingredient> get _filtered {
    if (_query.isEmpty) return _ingredients;
    return _ingredients
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Meal _buildMeal() {
    final name = _nameController.text.trim();
    return Meal(
      id: widget.meal.id,
      type: widget.meal.type,
      name: name.isEmpty ? widget.meal.name : name,
      calories: widget.meal.calories,
      proteinGrams: widget.meal.proteinGrams,
      fatGrams: widget.meal.fatGrams,
      carbsGrams: widget.meal.carbsGrams,
      ingredients: List<Ingredient>.from(_ingredients),
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

  Future<void> _addIngredients() async {
    final result = await Navigator.push<List<FoodItem>>(
      context,
      MaterialPageRoute(builder: (_) => const FoodSearchView()),
    );
    if (result == null || result.isEmpty) return;
    setState(() {
      for (final item in result) {
        _ingredients.add(
          Ingredient(
            id: 'ing_${DateTime.now().millisecondsSinceEpoch}_${item.id}',
            name: item.name,
            emoji: item.emoji,
            serving: item.serving,
            calories: item.calories,
            proteinGrams: item.proteinGrams,
            carbsGrams: item.carbsGrams,
            fatGrams: item.fatGrams,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
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
        SizedBox(height: 10.h),
        Text(
          widget.meal.type,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
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
                '${widget.meal.calories} Calories',
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
                'p:${widget.meal.proteinGrams}g . c:${widget.meal.carbsGrams}g . f:${widget.meal.fatGrams}g',
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
                onSave: () => Navigator.pop(context, _buildMeal()),
              ),
              _NoteTab(controller: _noteTabController),
            ],
          ),
        ),
      ],
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
