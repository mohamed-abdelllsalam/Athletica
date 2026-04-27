import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/nutrition_plan.dart';
import 'package:athletica/features/coach/plan/presentation/views/meal_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NutritionPlanDetailViewBody extends StatefulWidget {
  const NutritionPlanDetailViewBody({super.key, required this.plan});

  final NutritionPlan plan;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _meals = List.from(widget.plan.meals);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
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
                  widget.plan.iconAsset,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.name,
                      style: AppTextStyles.bold24(context).copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                      ),
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
                          '${widget.plan.calories} calories',
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _CategoryBadge(category: widget.plan.category),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: AppColors.textSecondary, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          widget.plan.updatedAgo,
                          style: AppTextStyles.meduim12(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: AppColors.textSecondary, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Used by ${widget.plan.clientCount} clients',
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
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => _showAssignSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon:
                  Icon(Icons.person_outline, color: Colors.white, size: 18.sp),
              label: Text(
                'Assign to client',
                style: AppTextStyles.medium14(context)
                    .copyWith(color: Colors.white),
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
            tabs: const [Tab(text: 'Overview'), Tab(text: 'Note')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(
                plan: widget.plan,
                meals: _meals,
                onAddMeal: () => setState(() => _meals.add(Meal(
                      id: 'm${_meals.length + 1}',
                      type: 'Meal ${_meals.length + 1}',
                      name: 'New Meal',
                      calories: 0,
                      proteinGrams: 0,
                      fatGrams: 0,
                      carbsGrams: 0,
                      ingredients: [],
                    ))),
                onMealTap: (meal) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailView(meal: meal),
                  ),
                ),
              ),
              _NoteTab(controller: _noteController),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => const _AssignToClientSheet(),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.plan,
    required this.meals,
    required this.onAddMeal,
    required this.onMealTap,
  });

  final NutritionPlan plan;
  final List<Meal> meals;
  final VoidCallback onAddMeal;
  final ValueChanged<Meal> onMealTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        Text(
          'Program Overview',
          style: AppTextStyles.semiBold14(context).copyWith(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          plan.description,
          style: AppTextStyles.medium14(context).copyWith(
            color: AppColors.textSecondary,
          ),
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
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: onAddMeal,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add,
                        color: AppColors.primaryBlue, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add Meal',
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        ...meals.map((meal) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _MealCard(meal: meal, onTap: () => onMealTap(meal)),
            )),
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
          style: AppTextStyles.bold24(context).copyWith(
            color: color,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: AppTextStyles.meduim12(context).copyWith(
            color: AppColors.textSecondary,
          ),
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
                    meal.type,
                    style: AppTextStyles.semiBold14(context).copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    meal.name,
                    style: AppTextStyles.medium14(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${meal.calories} CAL . ${meal.proteinGrams}G Protein',
                    style: AppTextStyles.meduim12(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
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
            style: AppTextStyles.semiBold14(context).copyWith(
              color: AppColors.textPrimary,
            ),
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
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type Your Note !',
                  hintStyle: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
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
                style: AppTextStyles.medium14(context)
                    .copyWith(color: Colors.white),
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
  const _AssignToClientSheet();

  @override
  State<_AssignToClientSheet> createState() => _AssignToClientSheetState();
}

class _AssignToClientSheetState extends State<_AssignToClientSheet> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime(2026, 6, 20);
  DateTime _endDate = DateTime(2026, 8, 20);
  int? _selectedClientIndex;

  static const List<String> _clientNames = [
    'Mohamed Salah',
    'Rayan',
    'Sayed Hafez',
    'Nour Ayman',
    'Anas',
    'Ahmed',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day},${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = _clientNames
        .where((n) => query.isEmpty || n.toLowerCase().contains(query))
        .toList();

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
            Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.medium14(context)
                      .copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.textSecondary, size: 20.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 80.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final name = filtered[index];
                  final isSelected = _selectedClientIndex == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedClientIndex = index),
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
                                    color: AppColors.primaryBlue, width: 2)
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
                            style: AppTextStyles.meduim11(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
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
            Row(
              children: [
                Expanded(
                  child: _DatePickerCard(
                    label: 'Start Data',
                    date: _formatDate(_startDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DatePickerCard(
                    label: 'End Data',
                    date: _formatDate(_endDate),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
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
                  style: AppTextStyles.medium14(context)
                      .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
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

class _DatePickerCard extends StatelessWidget {
  const _DatePickerCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.meduim11(context)
                      .copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: 2.h),
                Text(
                  date,
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
