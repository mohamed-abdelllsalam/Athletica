import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/clients/domain/entities/client_detail.dart';
import 'package:athletica/features/coach/clients/presentation/cubits/client_detail_cubit.dart';
import 'package:athletica/features/coach/clients/presentation/views/coach_client_info_view.dart';
import 'package:athletica/features/coach/messages/domain/entities/chat_contact.dart';
import 'package:athletica/features/coach/messages/presentation/views/coach_chat_view.dart';
import 'package:athletica/features/coach/nutrition_templates/presentation/cubits/assign_plan_cubit.dart';
import 'package:athletica/features/coach/plan/presentation/views/customize_workout_assignment_view.dart';
import 'package:athletica/features/workout/domain/entities/workout_template.dart';
import 'package:athletica/features/workout/domain/usecases/get_workout_template_detail_usecase.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_templates_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachClientDetailViewBody extends StatefulWidget {
  const CoachClientDetailViewBody({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  @override
  State<CoachClientDetailViewBody> createState() =>
      _CoachClientDetailViewBodyState();
}

class _CoachClientDetailViewBodyState extends State<CoachClientDetailViewBody> {
  int _selectedTabIndex = 0;

  static const _tabs = ['Daily', 'Weekly', 'Monthly'];
  static const _dailyData = [0.80, 0.75, 0.45, 0.60, 0.75, 0.85, 0.95];
  static const _weeklyData = [0.50, 0.60, 0.70, 0.65, 0.80, 0.72, 0.90];
  static const _monthlyData = [0.30, 0.45, 0.55, 0.60, 0.70, 0.80, 0.85];
  static const _xLabels = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Today'];

  List<double> get _currentData {
    switch (_selectedTabIndex) {
      case 1:
        return _weeklyData;
      case 2:
        return _monthlyData;
      default:
        return _dailyData;
    }
  }

  void _confirmDeactivate(BuildContext context, NutritionPlanSummary plan) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Deactivate Plan',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will deactivate "${plan.title}" and remove all meal logs. The client will no longer see this plan.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ClientDetailCubit>().deleteNutritionPlan(plan.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: BlocBuilder<ClientDetailCubit, ClientDetailState>(
          builder: (context, state) {
            if (state is ClientDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ClientDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: AppTextStyles.medium14(context)
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ClientDetailCubit>()
                            .loadClientDetail(widget.clientId);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ClientDetailLoaded) {
              return _buildContent(context, state.detail);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClientDetail detail) {
    final client = detail.client;
    return Column(
      children: [
        _buildAppBar(context, client),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildProfileSection(context, client),
                SizedBox(height: 16.h),
                _buildMessageButton(context, client),
                SizedBox(height: 12.h),
                _buildInformationButton(context, detail),
                SizedBox(height: 24.h),
                _buildAssignedPlanSection(context, detail),
                SizedBox(height: 24.h),
                _buildProgressOverviewSection(context, detail),
                SizedBox(height: 8.h),
                Divider(color: AppColors.surfaceDark, thickness: 1),
                SizedBox(height: 8.h),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, ClientProfile client) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            client.displayName,
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ClientProfile client) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            width: 90.r,
            height: 90.r,
            color: AppColors.surfaceDark,
            child: client.profileImage != null
                ? Image.network(client.profileImage!, fit: BoxFit.cover)
                : Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 40.sp,
                  ),
          ),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.displayName,
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 4.h),
            if (client.goal != null)
              Text(
                client.goal!,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _StatItem(
                  label: 'Height',
                  value: '${client.heightCm ?? '--'} Cm',
                  context: context,
                ),
                SizedBox(width: 24.w),
                _StatItem(
                  label: 'Weight',
                  value: '${client.weightKg ?? '--'} Kg',
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageButton(BuildContext context, ClientProfile client) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () {
          final contact = ChatContact(
            id: client.id,
            name: client.displayName,
            goals: client.goal != null ? [client.goal!] : [],
            heightCm: client.heightCm?.toInt(),
            weightKg: client.weightKg?.toInt(),
          );
          Navigator.pushNamed(
            context,
            CoachChatView.routeName,
            arguments: contact,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Message ${client.displayName.split(' ').first}',
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInformationButton(BuildContext context, ClientDetail detail) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(
          context,
          CoachClientInfoView.routeName,
          arguments: detail,
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.surfaceDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryBlue, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Information',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeactivateWorkout(
    BuildContext context,
    String planId,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Deactivate Plan',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will deactivate "$title". The client will no longer see this plan.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Clear the local fallback so the card disappears even though
              // the detail endpoint still returns workout_plan: null.
              setState(() {
                _justAssignedWorkoutTitle = null;
                _justAssignedWorkoutSubtitle = null;
                _justAssignedWorkoutId = null;
              });
              context.read<ClientDetailCubit>().deleteWorkoutPlan(planId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Deactivate',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedPlanSection(BuildContext context, ClientDetail detail) {
    final nutritionPlan = detail.nutritionPlan;
    final workoutTitle =
        _justAssignedWorkoutTitle ?? _workoutTitle(detail.workoutPlan);
    final workoutSubtitle =
        _justAssignedWorkoutSubtitle ?? _workoutSubtitle(detail.workoutPlan);
    final workoutPlanId =
        _workoutId(detail.workoutPlan) ?? _justAssignedWorkoutId;

    Future<void> reload() async {
      if (context.mounted) {
        context.read<ClientDetailCubit>().loadClientDetail(widget.clientId);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Plan',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        if (nutritionPlan != null)
          _PlanCard(
            iconData: Icons.receipt_long,
            iconBgColor: AppColors.streakGreen,
            title: nutritionPlan.title,
            subtitle: nutritionPlan.description ?? 'Nutrition Plan',
            isActive: nutritionPlan.isActive,
            onDelete: () => _confirmDeactivate(context, nutritionPlan),
          )
        else
          _AssignPlanCard(
            label: 'Assign Nutrition Plan',
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                'nutrition-templates-list',
                arguments: {'clientId': detail.client.id},
              );
              await reload();
            },
          ),
        SizedBox(height: 10.h),
        if (workoutTitle != null)
          _PlanCard(
            iconData: Icons.fitness_center,
            iconBgColor: AppColors.primaryBlue,
            title: workoutTitle,
            subtitle: workoutSubtitle,
            onDelete: workoutPlanId != null
                ? () => _confirmDeactivateWorkout(
                    context,
                    workoutPlanId,
                    workoutTitle,
                  )
                : null,
          )
        else
          _AssignPlanCard(
            label: 'Assign Workout Plan',
            onPressed: () => _openWorkoutAssignSheet(context, detail),
          ),
      ],
    );
  }

  String? _workoutTitle(dynamic workoutPlan) {
    if (workoutPlan is Map<String, dynamic>) {
      final title = workoutPlan['title'] as String?;
      if (title != null && title.isNotEmpty) return title;
    }
    return null;
  }

  String? _workoutId(dynamic workoutPlan) {
    if (workoutPlan is Map<String, dynamic>) {
      final id = workoutPlan['id'] as String?;
      if (id != null && id.isNotEmpty) return id;
    }
    return null;
  }

  String _workoutSubtitle(dynamic workoutPlan) {
    if (workoutPlan is Map<String, dynamic>) {
      final description = workoutPlan['description'] as String?;
      if (description != null && description.isNotEmpty) return description;
    }
    return 'Workout Plan';
  }

  /// The backend still returns `workout_plan: null` on the client detail
  /// (placeholder until the workout feature ships server-side), so a
  /// reload alone can't show the new assignment. The just-assigned plan
  /// is therefore kept locally and shown until the backend provides it.
  String? _justAssignedWorkoutTitle;
  String? _justAssignedWorkoutSubtitle;
  String? _justAssignedWorkoutId;

  /// Opens the plan picker as a full screen (same style as the workout
  /// library) instead of navigating to the workout library screen itself.
  /// Picking a plan pushes the sets/reps customization for this client.
  Future<void> _openWorkoutAssignSheet(
    BuildContext context,
    ClientDetail detail,
  ) async {
    final assigned =
        await Navigator.push<({String planId, String title, String subtitle})>(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => sl<WorkoutTemplatesCubit>()..load(),
                ),
                BlocProvider(
                  create: (_) => sl<AssignPlanCubit>()..loadClients(),
                ),
              ],
              child: _SelectWorkoutTemplateView(
                clientName: detail.client.displayName,
                clientEmail: detail.client.email,
              ),
            ),
          ),
        );
    if (assigned != null && context.mounted) {
      final cubit = context.read<ClientDetailCubit>();
      await cubit.loadClientDetail(widget.clientId);
      if (!context.mounted) return;
      final reloaded = cubit.state;
      final backendTitle = reloaded is ClientDetailLoaded
          ? _workoutTitle(reloaded.detail.workoutPlan)
          : null;
      setState(() {
        if (backendTitle != null) {
          // Backend now provides the plan — local fallback no longer needed.
          _justAssignedWorkoutTitle = null;
          _justAssignedWorkoutSubtitle = null;
          _justAssignedWorkoutId = null;
        } else {
          _justAssignedWorkoutTitle = assigned.title;
          _justAssignedWorkoutSubtitle = assigned.subtitle;
          _justAssignedWorkoutId = assigned.planId;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout assigned successfully')),
      );
    }
  }

  Widget _buildProgressOverviewSection(BuildContext context, ClientDetail detail) {
    final nutritionStreak = detail.nutritionStreak;
    final workoutStreak = detail.workoutStreak;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        SizedBox(height: 12.h),
        _buildStreakRow(
          context,
          title: 'Nutrition Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFF5ED1A0),
          currentStreak: nutritionStreak.current,
          lastDate: nutritionStreak.lastDate,
        ),
        SizedBox(height: 10.h),
        _buildStreakRow(
          context,
          title: 'Workout Streak',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFB76CFF),
          currentStreak: workoutStreak.current,
          lastDate: workoutStreak.lastDate,
          showLastDate: false,
        ),
        SizedBox(height: 16.h),
        _TabSelector(
          tabs: _tabs,
          selectedIndex: _selectedTabIndex,
          onTabSelected: (i) => setState(() => _selectedTabIndex = i),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 200.h,
          child: _LineChart(dataPoints: _currentData, xLabels: _xLabels),
        ),
      ],
    );
  }

  Widget _buildStreakRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required int currentStreak,
    required String? lastDate,
    bool showLastDate = true,
  }) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      if (i == 6) return 'Today';
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    if (showLastDate && lastDate != null)
                      Text(
                        'Last: $lastDate',
                        style: AppTextStyles.meduim11(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(days.length, (index) {
                    final isDone = index < currentStreak;
                    return Column(
                      children: [
                        Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: isDone
                                ? iconColor.withValues(alpha: 0.18)
                                : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? iconColor
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.65,
                                    ),
                              width: 1.3,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : Icons.close_rounded,
                            size: 14.sp,
                            color: isDone ? iconColor : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          days[index],
                          style: AppTextStyles.meduim11(
                            context,
                          ).copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Tab Selector ----------

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                margin: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTextStyles.medium14(context).copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------- Line Chart ----------

class _LineChart extends StatelessWidget {
  const _LineChart({required this.dataPoints, required this.xLabels});

  final List<double> dataPoints;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(dataPoints: dataPoints, xLabels: xLabels),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.dataPoints, required this.xLabels});

  final List<double> dataPoints;
  final List<String> xLabels;

  static const _yLabels = ['100%', '75%', '50%', '25%', '0%'];
  static const _leftPad = 44.0;
  static const _bottomPad = 22.0;
  static const _rightPad = 8.0;
  static const _topPad = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 1;

    for (int i = 0; i < _yLabels.length; i++) {
      final ratio = i / (_yLabels.length - 1);
      final y = _topPad + chartH * ratio;
      canvas.drawLine(
        Offset(_leftPad, y),
        Offset(_leftPad + chartW, y),
        gridPaint,
      );
      _paintText(
        canvas,
        _yLabels[i],
        Offset(0, y - 7),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }

    if (dataPoints.length < 2) return;

    // Gradient fill under the line
    final fillPath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        fillPath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }
    fillPath.lineTo(_leftPad + chartW, _topPad + chartH);
    fillPath.lineTo(_leftPad, _topPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5273E0).withValues(alpha: 0.3),
            const Color(0xFF5273E0).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH)),
    );

    // Smooth bezier line
    final linePath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final x = _leftPad + chartW * i / (dataPoints.length - 1);
      final y = _topPad + chartH * (1 - dataPoints[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        final prevX = _leftPad + chartW * (i - 1) / (dataPoints.length - 1);
        final prevY = _topPad + chartH * (1 - dataPoints[i - 1]);
        final cpX = prevX + (x - prevX) / 2;
        linePath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.streakPurple
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // X-axis labels
    _paintText(
      canvas,
      'Days',
      Offset(0, size.height - _bottomPad + 5),
      const Color(0xFF6B6B6B),
      9.0,
    );
    for (int i = 0; i < xLabels.length; i++) {
      final x = _leftPad + chartW * i / (xLabels.length - 1);
      _paintText(
        canvas,
        xLabels[i],
        Offset(x - xLabels[i].length * 2.8, size.height - _bottomPad + 5),
        const Color(0xFF9E9E9E),
        9.5,
      );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.dataPoints != dataPoints || old.xLabels != xLabels;
}

// ---------- Plan Card ----------

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.iconData,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.isActive = true,
    this.onDelete,
  });

  final IconData iconData;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: isActive
            ? null
            : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(iconData, color: iconBgColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiBold14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyles.meduim12(
                    context,
                  ).copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- Assign Plan Card ----------

class _AssignPlanCard extends StatelessWidget {
  const _AssignPlanCard({required this.onPressed, this.label = 'Assign Plan'});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryBlue,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.semiBold14(
                context,
              ).copyWith(color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Stat Item ----------

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.context,
  });

  final String label;
  final String value;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.meduim12(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ---------- Workout plan picker (full screen, inline assign) ----------

/// Full screen listing the coach's workout templates — same style as the
/// workout library — so a workout can be assigned without leaving the
/// client profile flow. Tapping a plan loads its full details (the list
/// API sends counts only) then pushes the sets/reps customization for
/// this client.
///
/// The list stays disabled until the roster is loaded and this client's
/// `coach_clients.id` relation id is resolved, so tapping a plan can
/// never hit a "still loading" state.
class _SelectWorkoutTemplateView extends StatefulWidget {
  const _SelectWorkoutTemplateView({
    required this.clientName,
    required this.clientEmail,
  });

  final String clientName;
  final String clientEmail;

  @override
  State<_SelectWorkoutTemplateView> createState() =>
      _SelectWorkoutTemplateViewState();
}

class _SelectWorkoutTemplateViewState
    extends State<_SelectWorkoutTemplateView> {
  String _query = '';
  String? _loadingId;

  List<WorkoutTemplateEntry> _filtered(List<WorkoutTemplateEntry> items) {
    if (_query.isEmpty) return items;
    final lower = _query.toLowerCase();
    return items
        .where(
          (t) =>
              t.title.toLowerCase().contains(lower) ||
              t.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> _pick(WorkoutTemplateEntry item, String relationId) async {
    if (_loadingId != null) return;
    setState(() => _loadingId = item.id);
    final result = await sl<GetWorkoutTemplateDetailUseCase>()(item.id);
    if (!mounted) return;
    switch (result) {
      case ApiError(:final failure):
        setState(() => _loadingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
        );
      case ApiSuccess(:final data):
        setState(() => _loadingId = null);
        final assignedPlanId = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => CustomizeWorkoutAssignmentView(
              template: data,
              coachClientId: relationId,
              clientName: widget.clientName,
            ),
          ),
        );
        if (!mounted) return;
        // Return the assigned plan info so the profile updates immediately
        // (the detail endpoint still returns workout_plan: null).
        if (assignedPlanId != null && assignedPlanId.isNotEmpty) {
          Navigator.pop(context, (
            planId: assignedPlanId,
            title: item.title,
            subtitle: item.description.isNotEmpty
                ? item.description
                : 'Workout Plan',
          ));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search plans...',
                    hintStyle: AppTextStyles.medium14(
                      context,
                    ).copyWith(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: BlocBuilder<
                WorkoutTemplatesCubit,
                WorkoutTemplatesState
              >(
                builder: (context, templatesState) {
                  return BlocBuilder<AssignPlanCubit, AssignPlanState>(
                    builder: (context, assignState) {
                      final items = switch (templatesState) {
                        WorkoutTemplatesLoaded(:final items) => items,
                        _ => null,
                      };
                      // coach_client_id must be the coach_clients.id relation
                      // id, resolved from the roster by the client's email.
                      final clients = switch (assignState) {
                        AssignPlanClientsLoaded(:final clients) => clients,
                        AssignPlanAssigning(:final clients) => clients,
                        AssignPlanError(:final clients) => clients,
                        _ => null,
                      };
                      if (items == null || clients == null) {
                        final templatesError =
                            templatesState is WorkoutTemplatesError
                            ? templatesState.message
                            : null;
                        final clientsError =
                            assignState is AssignPlanClientsError
                            ? assignState.message
                            : null;
                        final error = templatesError ?? clientsError;
                        if (error != null) return _buildError(error);
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final matchEmail = widget.clientEmail
                          .trim()
                          .toLowerCase();
                      final match = clients
                          .where(
                            (c) =>
                                c.email.trim().toLowerCase() == matchEmail,
                          )
                          .firstOrNull;
                      if (match == null) {
                        return _buildError(
                          'Client not found in your roster',
                          showRetry: false,
                        );
                      }
                      return _buildList(items, match.relationId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Select Workout Plan',
            style: AppTextStyles.semiBold15(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, {bool showRetry = true}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (showRetry) ...[
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<WorkoutTemplatesCubit>().load();
                  context.read<AssignPlanCubit>().loadClients();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<WorkoutTemplateEntry> items, String relationId) {
    final filtered = _filtered(items);
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No workout plans available',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final isLoading = item.id == _loadingId;
        return GestureDetector(
          onTap: () => _pick(item, relationId),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.surfaceDark, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.fitness_center,
                          color: AppColors.primaryBlue,
                          size: 20.sp,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.semiBold14(
                          context,
                        ).copyWith(color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.dayCount} days • ${item.exerciseCount} exercises',
                        style: AppTextStyles.meduim12(
                          context,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
