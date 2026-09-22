import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/services/token_storage_service.dart';
import 'package:athletica/core/utils/api_result.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_action_button.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_template_sheet.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/sheet_drag_handle.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_error_view.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_item.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_list_view.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/template_search_field.dart';
import 'package:athletica/features/coach/nutrition_templates/domain/usecases/get_nutrition_templates_usecase.dart';
import 'package:athletica/features/coach/workout_templates/domain/usecases/get_workout_templates_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssignTemplateSheetState extends State<AssignTemplateSheet> {
  String _query = '';
  bool _isLoading = true;
  String? _error;
  List<TemplateItem> _templates = [];
  String? _selectedId;
  bool _isAssigning = false;

  bool get _isWorkout => widget.type == AssignType.workout;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isWorkout) {
        final useCase = sl<GetWorkoutTemplatesUseCase>();
        final trainerId = await TokenStorageService.instance.getTrainerId();
        if (trainerId == null) {
          setState(() {
            _error = 'Trainer ID not found';
            _isLoading = false;
          });
          return;
        }
        final result = await useCase(trainerId);
        switch (result) {
          case ApiSuccess(:final data):
            setState(() {
              _templates = data
                  .map((t) => TemplateItem(
                        id: t.id,
                        name: t.title,
                        subtitle: t.level,
                      ))
                  .toList();
              _isLoading = false;
            });
          case ApiError(:final failure):
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
        }
      } else {
        final useCase = sl<GetNutritionTemplatesUseCase>();
        final result = await useCase(pageSize: 50);
        switch (result) {
          case ApiSuccess(:final data):
            setState(() {
              _templates = data.templates
                  .map((t) => TemplateItem(
                        id: t.id,
                        name: t.title,
                        subtitle: t.description,
                        mealCount: t.mealCount,
                      ))
                  .toList();
              _isLoading = false;
            });
          case ApiError(:final failure):
            setState(() {
              _error = failure.message;
              _isLoading = false;
            });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<TemplateItem> get _filtered {
    if (_query.isEmpty) return _templates;
    final lower = _query.toLowerCase();
    return _templates
        .where((t) => t.name.toLowerCase().contains(lower))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            8.h,
            20.w,
            MediaQuery.of(context).viewInsets.bottom + 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetDragHandle(),
              SizedBox(height: 12.h),
              Text(
                _isWorkout
                    ? 'Select Workout Template'
                    : 'Select Nutrition Template',
                style: AppTextStyles.bold20(context)
                    .copyWith(color: AppColors.textPrimary),
              ),
              SizedBox(height: 16.h),
              TemplateSearchField(
                onChanged: (v) => setState(() => _query = v),
              ),
              SizedBox(height: 16.h),
              Expanded(child: _buildBody(scrollController)),
              SizedBox(height: 12.h),
              AssignActionButton(
                hasSelection: _selectedId != null,
                isAssigning: _isAssigning,
                onPressed: () {
                  if (_selectedId != null) {
                    _assign();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return TemplateErrorView(message: _error!, onRetry: _loadTemplates);
    }

    return TemplateListView(
      scrollController: scrollController,
      items: _filtered,
      selectedId: _selectedId,
      onSelect: (item) => setState(() => _selectedId = item.id),
    );
  }

  Future<void> _assign() async {
    if (_selectedId == null || _isAssigning) return;

    setState(() => _isAssigning = true);

    final cubit = context.read<AssignedCubit>();
    if (_isWorkout) {
      await cubit.assignWorkout(_selectedId!);
    } else {
      await cubit.assignNutrition(_selectedId!);
    }

    if (!mounted) return;

    final actionState = cubit.actionState;
    if (actionState is AssignActionSuccess) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isWorkout
                ? 'Workout plan assigned!'
                : 'Nutrition plan assigned!',
          ),
        ),
      );
    } else if (actionState is AssignActionError) {
      setState(() => _isAssigning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionState.message)),
      );
    }
  }
}
