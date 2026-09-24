import 'dart:io';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/chat/presentation/models/chat_route_args.dart';
import 'package:athletica/features/chat/presentation/views/chat_view.dart';
import 'package:athletica/features/client_coach/domain/usecases/get_my_coach_usecase.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:athletica/features/profile/presentation/cubits/profile_state.dart';
import 'package:athletica/features/profile/presentation/views/edit_profile_view.dart';
import 'package:athletica/features/profile/presentation/views/profile_info_view.dart';
import 'package:athletica/features/profile/presentation/views/widgets/profile_assigned_plans_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  int _selectedTabIndex = 0;
  final ImagePicker _picker = ImagePicker();
  File? _pendingImage;

  static const _tabs = ['Daily', 'Weekly', 'Monthly'];
  static const _dailyData = [0.80, 0.75, 0.45, 0.60, 0.75, 0.85, 0.95];
  static const _weeklyData = [0.50, 0.60, 0.70, 0.65, 0.80, 0.72, 0.90];
  static const _monthlyData = [0.30, 0.45, 0.55, 0.60, 0.70, 0.80, 0.85];
  static const _xLabels = ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Today'];

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Photo',
            toolbarColor: AppColors.primaryAppColor,
            toolbarWidgetColor: AppColors.textPrimary,
            activeControlsWidgetColor: AppColors.primaryBlue,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() => _pendingImage = File(croppedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openCoachChat() async {
    final result = await sl<GetMyCoachUseCase>()();
    if (!mounted) return;
    switch (result) {
      case ApiSuccess(:final data):
        final assignmentId = data?.assignmentId;
        if (assignmentId == null || assignmentId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No assigned coach is available.')),
          );
          return;
        }
        Navigator.pushNamed(
          context,
          ChatView.routeName,
          arguments: ChatRouteArgs(
            title: 'Coach',
            coachClientId: assignmentId,
            canStartConversation: true,
          ),
        );
      case ApiError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  void _saveImage() {
    if (_pendingImage != null) {
      context.read<ProfileCubit>().uploadImage(_pendingImage!);
      setState(() => _pendingImage = null);
    }
  }

  void _cancelPreview() {
    setState(() => _pendingImage = null);
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Change Photo',
              style: AppTextStyles.bold20(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _PhotoOptionButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildProfileSection(context),
                    SizedBox(height: 16.h),
                    _buildEditButtons(context),
                    SizedBox(height: 16.h),
                    _buildMessageCoachButton(context),
                    SizedBox(height: 12.h),
                    _buildInformationButton(context),
                    SizedBox(height: 24.h),
                    _buildAssignedPlanSection(context),
                    SizedBox(height: 24.h),
                    _buildProgressOverviewSection(context),
                    SizedBox(height: 8.h),
                    Divider(color: AppColors.surfaceDark, thickness: 1),
                    SizedBox(height: 8.h),
                    _buildSubscriptionInfoSection(context),
                    SizedBox(height: 32.h),
                  ],
                ),
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
          BlocBuilder<ProfileCubit, ProfileState>(
            buildWhen: (prev, curr) =>
                curr is ProfileLoaded || curr is ProfileLoading,
            builder: (context, state) {
              final name =
                  state is ProfileLoaded ? state.profile.name : '...';
              return Text(
                name,
                style: AppTextStyles.semiBold15(context)
                    .copyWith(color: AppColors.textPrimary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          curr is ProfileLoaded || curr is ProfileLoading,
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final name = profile?.name ?? '—';
        final imageUrl = profile?.profileImage;
        final height =
            profile?.height != null ? '${profile!.height} Cm' : '—';
        final weight =
            profile?.weight != null ? '${profile!.weight} Kg' : '—';

        return Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      width: 90.r,
                      height: 90.r,
                      color: AppColors.surfaceDark,
                      child: _pendingImage != null
                          ? Image.file(
                              _pendingImage!,
                              fit: BoxFit.cover,
                            )
                          : (imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 40.sp,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: AppColors.textSecondary,
                                  size: 40.sp,
                                )),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bold20(context)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _StatItem(
                          label: 'Height',
                          value: height,
                          context: context,
                        ),
                        SizedBox(width: 24.w),
                        _StatItem(
                          label: 'Weight',
                          value: weight,
                          context: context,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (_pendingImage != null) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'Save Photo',
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelPreview,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.textTertiary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.semiBold14(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEditButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _showImagePickerDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.textSecondary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'Edit Photo',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final cubit = context.read<ProfileCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const EditProfileView(),
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.textSecondary, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              'Edit Profile',
              style: AppTextStyles.medium14(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCoachButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _openCoachChat,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Text(
          'Message Coach',
          style: AppTextStyles.semiBold15(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInformationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.pushNamed(context, ProfileInfoView.routeName),
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

  Widget _buildAssignedPlanSection(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) => curr is! ProfileInitial,
      builder: (context, state) {
        final profile = switch (state) {
          ProfileLoaded(:final profile) => profile,
          ProfileUpdating(:final profile) => profile,
          ProfileImageUploading(:final profile) => profile,
          ProfileImageUploaded(:final profile) => profile,
          ProfileImageDeleted(:final profile) => profile,
          ProfileError(:final profile) => profile,
          _ => null,
        };
        return ProfileAssignedPlansSection(profile: profile);
      },
    );
  }

  Widget _buildProgressOverviewSection(BuildContext context) {
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

  Widget _buildSubscriptionInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subscription Information',
              style: AppTextStyles.semiBold15(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.streakGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  'Active',
                  style: AppTextStyles.medium14(context).copyWith(
                    color: AppColors.streakGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _SubscriptionRow(
          icon: Icons.access_time_rounded,
          label: 'Duration',
          value: '1 Month',
        ),
        SizedBox(height: 14.h),
        _SubscriptionRow(
          icon: Icons.calendar_month_outlined,
          label: 'Start date',
          value: '15 May 2026',
        ),
        SizedBox(height: 14.h),
        _SubscriptionRow(
          icon: Icons.calendar_month_outlined,
          label: 'End date',
          value: '15 Jun 2026',
          trailingHighlight: '(In 18 days)',
        ),
      ],
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

// ---------- Subscription Row ----------

class _SubscriptionRow extends StatelessWidget {
  const _SubscriptionRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailingHighlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? trailingHighlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textPrimary),
              ),
              if (trailingHighlight != null)
                TextSpan(
                  text: ' $trailingHighlight',
                  style: AppTextStyles.medium14(
                    context,
                  ).copyWith(color: AppColors.streakFire),
                ),
            ],
          ),
        ),
      ],
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

// ---------- Photo Option Button ----------

class _PhotoOptionButton extends StatelessWidget {
  const _PhotoOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.textTertiary, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 26.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.medium13(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
