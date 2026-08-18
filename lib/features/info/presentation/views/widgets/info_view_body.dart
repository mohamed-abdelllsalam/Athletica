import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/domain/entities/client_question.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_questions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoViewBody extends StatefulWidget {
  const InfoViewBody({super.key});

  @override
  State<InfoViewBody> createState() => _InfoViewBodyState();
}

class _InfoViewBodyState extends State<InfoViewBody> {
  final Map<String, int> _selections = {};
  List<ClientQuestion> _questions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InfoCubit>().loadQuestions();
    });
  }

  int _answeredCount() =>
      _questions.where((q) => _selections.containsKey(q.id)).length;

  void _submit() {
    final missing = _questions.any((q) => !_selections.containsKey(q.id));
    if (missing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before continuing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.read<InfoCubit>().submitAnswers(Map.of(_selections));
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            CustomButton(
              onPressed: () => context.read<InfoCubit>().loadQuestions(),
              text: 'Try Again',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsFlow(BuildContext context, InfoState state) {
    final answered = _answeredCount();
    final progress = _questions.isEmpty ? 0.0 : answered / _questions.length;
    final allAnswered = _questions.every((q) => _selections.containsKey(q.id));
    final isLoading = state is InfoLoading;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: InfoQuestionsPage(
              questions: _questions,
              selections: _selections,
              onSelected: (questionId, choiceIndex) {
                setState(() => _selections[questionId] = choiceIndex);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4.h,
                    backgroundColor: const Color(0xFF2C2C2C),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5273E0),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                if (!allAnswered && !isLoading) ...[
                  Text(
                    'Please answer all questions to submit',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF5273E0))
                    : CustomButton(
                        onPressed: allAnswered ? _submit : null,
                        text: 'Submit',
                      ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InfoCubit, InfoState>(
      listener: (context, state) {
        if (state is InfoQuestionsLoaded) {
          if (mounted) setState(() => _questions = state.questions);
        } else if (state is InfoSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeView.routeName,
            (route) => false,
          );
        } else if (state is InfoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is InfoInitial || state is InfoQuestionsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF5273E0)),
          );
        }
        if (state is InfoQuestionsError) {
          return _buildError(context, state.message);
        }
        if (_questions.isEmpty) {
          return _buildError(context, 'No questions available right now.');
        }
        return _buildQuestionsFlow(context, state);
      },
    );
  }
}
