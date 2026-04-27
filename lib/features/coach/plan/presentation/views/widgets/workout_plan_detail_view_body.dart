import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/workout_day_exercises_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WorkoutPlanDetailViewBody extends StatefulWidget {
  const WorkoutPlanDetailViewBody({
    super.key,
    required this.program,
    this.isCreateMode = false,
  });

  final WorkoutProgram program;
  final bool isCreateMode;

  @override
  State<WorkoutPlanDetailViewBody> createState() =>
      _WorkoutPlanDetailViewBodyState();
}

class _WorkoutPlanDetailViewBodyState extends State<WorkoutPlanDetailViewBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ProgramDay> _days;
  late List<TextEditingController> _dayNameControllers;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late String _selectedCategory;

  static const List<Color> _dayColors = [
    Color(0xFF3D2E8A),
    Color(0xFF2E5EA8),
    Color(0xFF2E8A4A),
    Color(0xFFB5541C),
    Color(0xFF6A2E8A),
    Color(0xFF1B6E6A),
  ];

  static const List<String> _categories = [
    'Strength',
    'Fat loss',
    'Boxing',
    'Mobility',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _days = List.from(widget.program.days);
    _dayNameControllers =
        _days.map((d) => TextEditingController(text: d.name)).toList();
    _nameController =
        TextEditingController(text: widget.program.name);
    _descriptionController =
        TextEditingController(text: widget.program.description);
    _noteController = TextEditingController();
    _selectedCategory = widget.program.category.isEmpty
        ? 'Custom'
        : widget.program.category;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    for (final c in _dayNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addDay() {
    setState(() {
      final dayNumber = _days.length + 1;
      _days.add(ProgramDay(
        dayNumber: dayNumber,
        name: 'Day $dayNumber',
        durationMinutes: 60,
        exercises: [],
      ));
      _dayNameControllers
          .add(TextEditingController(text: 'Day $dayNumber'));
    });
  }

  void _removeDay(int index) {
    setState(() {
      _dayNameControllers[index].dispose();
      _days.removeAt(index);
      _dayNameControllers.removeAt(index);
    });
  }

  WorkoutProgram _buildProgram() {
    final name = _nameController.text.trim();
    return WorkoutProgram(
      id: widget.program.id,
      name: name.isEmpty ? 'New Plan' : name,
      category: _selectedCategory,
      splitType: '${_days.length} Days Split',
      updatedAgo: 'Just created',
      clientCount: 0,
      iconAsset: widget.program.iconAsset,
      description: _descriptionController.text.trim(),
      days: _days,
    );
  }

  Future<bool> _onWillPop() async {
    if (!widget.isCreateMode) return true;
    final hasContent = _nameController.text.trim().isNotEmpty ||
        _days.isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty;
    if (!hasContent) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Discard changes?',
          style: AppTextStyles.semiBold14(context)
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'You have unsaved changes. Leave without saving?',
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Stay',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Discard',
              style: AppTextStyles.medium14(context)
                  .copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.pop(context);
      },
      child: Column(
        children: [
          SizedBox(height: 20.h),
          // Back chevron
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && context.mounted) Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
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
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SvgPicture.asset(
                    widget.program.iconAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan Name',
                        style: AppTextStyles.meduim12(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Editable name in create mode; static text in edit mode
                      if (widget.isCreateMode)
                        _EditableNameField(controller: _nameController)
                      else
                        Text(
                          widget.program.name,
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
                            '${_days.length} Days Split',
                            style: AppTextStyles.meduim12(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
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
                            _CategoryBadge(category: widget.program.category),
                        ],
                      ),
                      if (!widget.isCreateMode) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: AppColors.textSecondary, size: 12.sp),
                            SizedBox(width: 4.w),
                            Text(
                              widget.program.updatedAgo,
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
                              'Used by ${widget.program.clientCount} clients',
                              style: AppTextStyles.meduim12(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
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
          // CTA button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: widget.isCreateMode
                  ? ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, _buildProgram()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Save Plan',
                        style: AppTextStyles.semiBold14(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _showAssignSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      icon: Icon(Icons.person_outline,
                          color: Colors.white, size: 18.sp),
                      label: Text(
                        'Assign to client',
                        style: AppTextStyles.semiBold14(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          // Tab bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.buttonColor,
              indicatorWeight: 2,
              labelStyle: AppTextStyles.semiBold14(context),
              unselectedLabelStyle: AppTextStyles.medium14(context),
              labelColor: AppColors.buttonColor,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [Tab(text: 'Overview'), Tab(text: 'Note')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  descriptionController: _descriptionController,
                  days: _days,
                  dayNameControllers: _dayNameControllers,
                  dayColors: _dayColors,
                  onAddDay: _addDay,
                  onRemoveDay: _removeDay,
                  onNavigateDay: (day) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutDayExercisesView(day: day),
                    ),
                  ),
                ),
                _NoteTab(controller: _noteController),
              ],
            ),
          ),
        ],
      ),
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

// ── Editable name field (create mode) ────────────────────────────────────────

class _EditableNameField extends StatelessWidget {
  const _EditableNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      style: AppTextStyles.bold24(context).copyWith(
        color: AppColors.textPrimary,
        fontSize: 20.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Plan name',
        hintStyle: AppTextStyles.bold24(context).copyWith(
          color: AppColors.textSecondary,
          fontSize: 20.sp,
        ),
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
        'Strength' => const Color(0xFF7B4FE8),
        'Fat loss' => const Color(0xFF7B4FE8),
        'Boxing' => const Color(0xFFD4752A),
        'Mobility' => const Color(0xFF2E6DB4),
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
          builder: (_) => _CategoryPickerSheet(
            categories: categories,
            selected: selected,
          ),
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
              style:
                  AppTextStyles.semiBold10(context).copyWith(color: _color),
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
            style: AppTextStyles.semiBold15(context)
                .copyWith(color: AppColors.textPrimary),
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
                  ? Icon(Icons.check,
                      color: AppColors.buttonColor, size: 18.sp)
                  : null,
              onTap: () => Navigator.pop(context, cat),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.descriptionController,
    required this.days,
    required this.dayNameControllers,
    required this.dayColors,
    required this.onAddDay,
    required this.onRemoveDay,
    required this.onNavigateDay,
  });

  final TextEditingController descriptionController;
  final List<ProgramDay> days;
  final List<TextEditingController> dayNameControllers;
  final List<Color> dayColors;
  final VoidCallback onAddDay;
  final ValueChanged<int> onRemoveDay;
  final ValueChanged<ProgramDay> onNavigateDay;

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
        TextField(
          controller: descriptionController,
          maxLines: null,
          style: AppTextStyles.medium14(context)
              .copyWith(color: AppColors.textSecondary),
          decoration: InputDecoration(
            hintText: 'Add a program description…',
            hintStyle: AppTextStyles.medium14(context)
                .copyWith(color: AppColors.textTertiary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Program Days',
              style: AppTextStyles.semiBold14(context).copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: onAddDay,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.buttonColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add,
                        color: AppColors.buttonColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Add New Day',
                      style: AppTextStyles.meduim12(context).copyWith(
                        color: AppColors.buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (days.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Text(
                'No days yet — tap + Add New Day',
                style: AppTextStyles.medium14(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...List.generate(days.length, (i) {
            final day = days[i];
            final color = dayColors[i % dayColors.length];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _DayRow(
                day: day,
                controller: dayNameControllers[i],
                color: color,
                onDelete: () => onRemoveDay(i),
                onNavigate: () => onNavigateDay(day),
              ),
            );
          }),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.controller,
    required this.color,
    required this.onDelete,
    required this.onNavigate,
  });

  final ProgramDay day;
  final TextEditingController controller;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                'D${day.dayNumber}',
                style: AppTextStyles.semiBold14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  style: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Day name',
                    hintStyle: AppTextStyles.medium14(context)
                        .copyWith(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.surfaceDark,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.surfaceDark,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: AppColors.buttonColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 8.h),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${day.exerciseCount} Exercises',
                  style: AppTextStyles.meduim12(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close,
                color: AppColors.textSecondary, size: 20.sp),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onNavigate,
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note tab ─────────────────────────────────────────────────────────────────

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
                style: AppTextStyles.medium14(context).copyWith(
                  color: AppColors.textPrimary,
                ),
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
                style: AppTextStyles.medium14(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category badge (edit mode) ────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final String category;

  Color get _color => switch (category) {
        'Strength' => const Color(0xFF7B4FE8),
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

// ── Assign to client bottom sheet ─────────────────────────────────────────────

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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
                                    color: AppColors.buttonColor, width: 2)
                                : null,
                          ),
                          child: Icon(Icons.person,
                              color: AppColors.textSecondary, size: 26.sp),
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
                    label: 'Start Date',
                    date: _formatDate(_startDate),
                    onTap: () => _pickDate(true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _DatePickerCard(
                    label: 'End Date',
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
                  style: AppTextStyles.semiBold14(context).copyWith(
                    color: Colors.white,
                  ),
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
            Icon(Icons.calendar_today_outlined,
                color: AppColors.textSecondary, size: 16.sp),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.meduim11(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
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
