import 'package:athletica/core/widgets/connection_error_view.dart';
import 'package:athletica/features/auth/presentation/cubits/auth_cubit.dart';
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
  final Map<String, Object> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};
  List<ClientQuestion> _questions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InfoCubit>().loadQuestions();
    });
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isAnswered(ClientQuestion question) {
    if (question.questionType == QuestionType.text) {
      final text = _textControllers[question.id]?.text.trim() ?? '';
      return text.isNotEmpty;
    }
    final answer = _answers[question.id];
    return answer is int && answer >= 0 && answer < question.choices.length;
  }

  int _answeredCount() => _questions.where(_isAnswered).length;

  void _submit() {
    final payload = <String, Object>{};
    for (final question in _questions) {
      if (!_isAnswered(question)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please answer "${question.question}" to continue.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Enforce the backend contract client-side:
      // choice -> integer index, text -> non-empty String.
      if (question.questionType == QuestionType.text) {
        payload[question.id] = _textControllers[question.id]!.text.trim();
      } else {
        payload[question.id] = _answers[question.id] as int;
      }
    }
    context.read<InfoCubit>().submitAnswers(payload);
  }

  void _onQuestionsLoaded(InfoQuestionsLoaded state) {
    for (final question in state.questions) {
      if (question.questionType != QuestionType.text) continue;
      final saved = state.savedAnswers[question.id];
      _textControllers.putIfAbsent(
        question.id,
        () => TextEditingController(text: saved is String ? saved : ''),
      );
    }
    setState(() {
      _questions = state.questions;
      _answers
        ..clear()
        ..addAll(state.savedAnswers);
    });
  }

  Widget _buildError(
    BuildContext context,
    String message, {
    bool retry = true,
  }) {
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
            if (retry)
              CustomButton(
                onPressed: () => context.read<InfoCubit>().loadQuestions(),
                text: 'Try Again',
              ),
            // Fail-closed escape: logout is the only way out of Info.
            TextButton(
              onPressed: () => context.read<AuthCubit>().logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsFlow(BuildContext context, InfoState state) {
    final answered = _answeredCount();
    final progress = _questions.isEmpty ? 0.0 : answered / _questions.length;
    final allAnswered = answered == _questions.length && _questions.isNotEmpty;
    final isLoading = state is InfoLoading;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: InfoQuestionsPage(
              questions: _questions,
              answers: _answers,
              textControllers: _textControllers,
              onSelected: (questionId, choiceIndex) {
                setState(() => _answers[questionId] = choiceIndex);
              },
              onTextChanged: (questionId, text) {
                // The TextField manages its own text via its controller;
                // rebuild only when the question's answered state flips.
                final question = _questions.firstWhere(
                  (q) => q.id == questionId,
                );
                final wasAnswered = _isAnswered(question);
                if (text.trim().isEmpty) {
                  _answers.remove(questionId);
                } else {
                  _answers[questionId] = text;
                }
                if (_isAnswered(question) != wasAnswered && mounted) {
                  setState(() {});
                }
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
          if (mounted) _onQuestionsLoaded(state);
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
        if (state case InfoQuestionsError(isConnectionError: true)) {
          return ConnectionErrorView(
            onRetry: () => context.read<InfoCubit>().loadQuestions(),
          );
        }
        if (state is InfoQuestionsError) {
          return _buildError(context, state.message);
        }
        if (_questions.isEmpty) {
          // Fail-closed: empty questionnaire never leads to Home.
          return _buildError(context, 'No questions available right now.');
        }
        return _buildQuestionsFlow(context, state);
      },
    );
  }
}
