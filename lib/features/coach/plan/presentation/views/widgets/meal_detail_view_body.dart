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
  late TextEditingController _nameController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _mealNoteController = TextEditingController();
  final TextEditingController _noteTabController = TextEditingController();
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
    _nameController.dispose();
    _searchController.dispose();
    _mealNoteController.dispose();
    _noteTabController.dispose();
    super.dispose();
  }

  List<Ingredient> get _filtered {
    if (_query.isEmpty) return _ingredients;
    return _ingredients
        .where((i) => i.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  int get _totalCalories => _ingredients.fold(0, (sum, i) => sum + i.calories);
  int get _totalProtein =>
      _ingredients.fold(0, (sum, i) => sum + i.proteinGrams);
  int get _totalFat => _ingredients.fold(0, (sum, i) => sum + i.fatGrams);
  int get _totalCarbs => _ingredients.fold(0, (sum, i) => sum + i.carbsGrams);

  Meal _buildMeal() {
    final name = _nameController.text.trim();
    return Meal(
      id: widget.meal.id,
      type: widget.meal.type,
      name: name.isEmpty ? widget.meal.name : name,
      calories: _totalCalories,
      proteinGrams: _totalProtein,
      fatGrams: _totalFat,
      carbsGrams: _totalCarbs,
      ingredients: List<Ingredient>.from(_ingredients),
    );
  }

  void _removeIngredient(Ingredient ingredient) {
    setState(() => _ingredients.removeWhere((i) => i.id == ingredient.id));
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
            style: AppTextStyles.bold24(
              context,
            ).copyWith(color: AppColors.textPrimary, fontSize: 22.sp),
            decoration: InputDecoration(
              hintText: 'Meal name',
              hintStyle: AppTextStyles.bold24(
                context,
              ).copyWith(color: AppColors.textSecondary, fontSize: 22.sp),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Stats bar
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

// ── Meal Details Tab ─────────────────────────────────────────────────────────-

class _MealDetailsTab extends StatelessWidget {
  const _MealDetailsTab({
    required this.searchController,
    required this.mealNoteController,
    required this.ingredients,
    required this.query,
    required this.onQueryChanged,
    required this.onRemove,
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
              ),
            ),
          ),
        SizedBox(height: 8.h),
        // Nutrition Summary
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
  const _IngredientCard({required this.ingredient, required this.onRemove});

  final Ingredient ingredient;
  final VoidCallback onRemove;

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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        ingredient.serving,
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
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

// ── Note Tab ─────────────────────────────────────────────────────────────────-

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
