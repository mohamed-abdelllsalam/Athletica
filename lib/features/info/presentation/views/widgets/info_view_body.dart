import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
import 'package:athletica/features/home/presentation/views/home_view.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_question_data.dart';
import 'package:athletica/features/info/presentation/views/widgets/info_questions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoViewBody extends StatefulWidget {
  const InfoViewBody({super.key});

  @override
  State<InfoViewBody> createState() => _InfoViewBodyState();
}

class _InfoViewBodyState extends State<InfoViewBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToNext() {
    if (_currentPage < kInfoQuestionPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, HomeView.routeName);
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

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: kInfoQuestionPages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => InfoQuestionsPage(
                questions: kInfoQuestionPages[index],
                onBack: _goToPrevious,
              ),
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
                CustomButton(onPressed: _goToNext, text: 'Submit'),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
