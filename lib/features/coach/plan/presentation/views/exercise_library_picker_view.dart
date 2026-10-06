import 'package:athletica/core/widgets/connection_error_view.dart';
import 'widgets/exercise_library_picker_states.dart';
import 'dart:async';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/bilingual_label.dart';
import 'package:athletica/core/widgets/exercise_video.dart';
import 'package:athletica/features/coach/plan/domain/entities/workout_program.dart';
import 'package:athletica/features/coach/plan/presentation/views/widgets/exercise_library_picker_components.dart';
import 'package:athletica/features/workout/domain/entities/workout_exercise_entry.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_cubit.dart';
import 'package:athletica/features/workout/presentation/cubits/workout_exercises_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Exercise library backed by `GET /workout/exercises`.
/// Visuals unchanged; data comes from the API (search + muscle filter).
/// Returns newly picked [LibraryExercise]s mapped from API entries.
class ExerciseLibraryPickerView extends StatelessWidget {
  const ExerciseLibraryPickerView({super.key, required this.alreadyAddedIds});

  final Set<String> alreadyAddedIds;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkoutExercisesCubit>()..load(),
      child: _PickerBody(alreadyAddedIds: alreadyAddedIds),
    );
  }
}

class _PickerBody extends StatefulWidget {
  const _PickerBody({required this.alreadyAddedIds});

  final Set<String> alreadyAddedIds;

  @override
  State<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends State<_PickerBody> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  String _selectedMuscle = 'All';
  late Set<String> _selectedIds;

  static const List<String> _muscles = [
    'All',
    'Back',
    'Chest',
    'Shoulder',
    'Arm',
    'Core',
    'Legs',
  ];

  /// Rail label → backend `bodyPart` exact-match value (DOC_6 §4.1).
  /// Unknown labels resolve to null (= unfiltered), never to a bad value.
  static const Map<String, String> _muscleToBodyPart = {
    'Back': 'back',
    'Chest': 'chest',
    'Shoulder': 'shoulders',
    'Arm': 'upper arms',
    'Core': 'waist',
    'Legs': 'upper legs',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedIds = Set.from(widget.alreadyAddedIds);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final muscle = _selectedMuscle == 'All' ? null : _selectedMuscle;
      context.read<WorkoutExercisesCubit>().searchLibrary(
        value,
        bodyPart: muscle == null ? null : _muscleToBodyPart[muscle],
      );
    });
  }

  void _onMuscleSelect(String muscle) {
    setState(() => _selectedMuscle = muscle);
    final selected = muscle == 'All' ? null : muscle;
    context.read<WorkoutExercisesCubit>().searchLibrary(
      _searchController.text,
      bodyPart: selected == null ? null : _muscleToBodyPart[selected],
    );
  }

  int get _newCount => _selectedIds.difference(widget.alreadyAddedIds).length;

  /// Selected entries keyed by id, independent of the currently visible
  /// search results. [_loaded] is overwritten on every search, so resolving
  /// selections from it would silently drop picks from previous result sets.
  final Map<String, WorkoutExerciseEntry> _selectedEntries = {};

  void _toggle(WorkoutExerciseEntry ex) {
    setState(() {
      if (_selectedIds.contains(ex.id)) {
        if (!widget.alreadyAddedIds.contains(ex.id)) {
          _selectedIds.remove(ex.id);
          _selectedEntries.remove(ex.id);
        }
      } else {
        _selectedIds.add(ex.id);
        _selectedEntries[ex.id] = ex;
      }
    });
  }

  void _submit() {
    final picked = _selectedEntries.values
        .where((e) => !widget.alreadyAddedIds.contains(e.id))
        .map(
          (e) => LibraryExercise(
            id: e.id,
            name: e.nameEn,
            nameEn: e.nameEn,
            nameAr: e.nameAr,
            muscleGroup: e.primaryMuscle,
            thumbnailUrl: e.thumbnailUrlMale,
            videoUrlMale: e.videoUrlMale,
            videoUrlFemale: e.videoUrlFemale,
          ),
        )
        .toList();
    Navigator.pop(context, picked);
  }

  @override
  Widget build(BuildContext context) {
    // 'All' stays first: selecting it clears the muscle filter and reloads
    // the full library.
    final muscles = _muscles;

    return Scaffold(
      backgroundColor: AppColors.primaryAppColor,
      body: SafeArea(
        child: Column(
          children: [
            ExercisePickerHeader(
              onBack: () => Navigator.pop(context, <LibraryExercise>[]),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ExercisePickerSearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        BlocBuilder<
                          WorkoutExercisesCubit,
                          WorkoutExercisesState
                        >(
                          builder: (context, state) => Column(children: [
 if (state is WorkoutExercisesLoaded && state.connectionError) ConnectionErrorView(compact: true, onRetry: () => context.read<WorkoutExercisesCubit>().searchLibrary(_searchController.text, bodyPart: _selectedMuscle)),
 Expanded(child: switch (state) {
 WorkoutExercisesError(connectionError: true) => ConnectionErrorView(onRetry: () => context.read<WorkoutExercisesCubit>().searchLibrary(_searchController.text, bodyPart: _selectedMuscle)),
                            WorkoutExercisesInitial() ||
                            WorkoutExercisesLoading() => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            WorkoutExercisesError(:final message) =>
                              CoachExercisePickerError(
                                message: message,
                                onRetry: () => context
                                    .read<WorkoutExercisesCubit>()
                                    .load(),
                              ),
                            WorkoutExercisesLoaded(:final items) =>
                              items.isEmpty
                                  ? const CoachExercisePickerEmpty()
                                  : ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.fromLTRB(
                                        16.w,
                                        0,
                                        6.w,
                                        100.h,
                                      ),
                                      itemCount: items.length,
                                      separatorBuilder: (_, _) =>
                                          SizedBox(height: 10.h),
                                      itemBuilder: (context, index) {
                                        final ex = items[index];
                                        final alreadyAdded = widget
                                            .alreadyAddedIds
                                            .contains(ex.id);
                                        final isSelected = _selectedIds
                                            .contains(ex.id);
                                        final name = buildBilingualLabel(
                                          primary: ex.nameEn,
                                          arabic: ex.nameAr,
                                          english: ex.nameEn,
                                        );
                                        return ExercisePickerResultCard(
                                          name: name,
                                          muscle: ex.primaryMuscle,
                                          thumbnailUrl: ex.thumbnailUrlMale,
                                          isSelected: isSelected,
                                          alreadyAdded: alreadyAdded,
                                          onTap: () => _toggle(ex),
                                          onPlay: () => showExerciseVideoDialog(
                                            context,
                                            title: name,
                                            videoUrl: resolveExerciseVideoUrl(
                                              maleUrl: ex.videoUrlMale,
                                              femaleUrl: ex.videoUrlFemale,
                                            ),
                                            thumbnailUrl: ex.thumbnailUrlMale,
                                          ),
                                        );
                                      },
                                    ),
                          }),
]),
                        ),
                  ),
                  ExercisePickerMuscleFilterRail(
                    muscles: muscles,
                    selectedMuscle: _selectedMuscle,
                    onSelect: _onMuscleSelect,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CoachExercisePickerAction(
        newCount: _newCount,
        onSubmit: _submit,
      ),
    );
  }
}

// ── Sub-widgets (visuals unchanged) ─────────────────────────────────────────
