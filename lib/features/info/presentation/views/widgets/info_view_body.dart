import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/cubits/info_cubit.dart';
import 'package:athletica/features/info/presentation/cubits/info_state.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_question_data.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Map<int, GlobalKey<InfoQuestionsPageState>> _pageKeys = {};

  GlobalKey<InfoQuestionsPageState> _keyFor(int index) =>
      _pageKeys.putIfAbsent(index, () => GlobalKey<InfoQuestionsPageState>());

  bool _currentPageAllAnswered() =>
      _keyFor(_currentPage).currentState?.allAnswered ?? false;

  void _goToNext() {
    if (!_currentPageAllAnswered()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before continuing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentPage < kInfoQuestionPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final allAnswers = <String, dynamic>{};
      for (int i = 0; i < kInfoQuestionPages.length; i++) {
        final pageAnswers = _keyFor(i).currentState?.answers ?? {};
        allAnswers.addAll(pageAnswers);
      }
      context.read<InfoCubit>().submitAnswers(allAnswers);
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentPage + 1) / kInfoQuestionPages.length;

    return BlocConsumer<InfoCubit, InfoState>(
      listener: (context, state) {
        if (state is InfoSuccess) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeView.routeName,
            (route) => false,
          );
        } else if (state is InfoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is InfoLoading;

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kInfoQuestionPages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) => InfoQuestionsPage(
                    key: _keyFor(index),
                    questions: kInfoQuestionPages[index],
                    onBack: _goToPrevious,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
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
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF5273E0),
                          )
                        : CustomButton(onPressed: _goToNext, text: 'Submit'),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
