import 'package:athletica/features/auth/presentation/views/widgets/custom_button.dart';
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

  static const List<List<String>> _questionPages = [
    [
      'Type Your Height',
      'Type Your Weight',
      'What are your primary fitness goals?',
      'Do you have any previous experience with personal training or fitness programs?',
      'Why is this goal important to you?',
      'Do you have any medical conditions?',
      'Are you currently taking any medications?',
      'What challenges do you expect to face?',
    ],
    [
      'Have you had any past injuries?',
      'Has a doctor ever advised you not to exercise?',
      'Are you currently exercising?',
      'How many days per week do you train?',
      'What type of exercise do you do?',
      'How many meals do you eat per day?',
    ],
    [
      'How would you rate your fitness level?',
      'What does your daily diet look like?',
      'How many meals do you eat per day?',
      'How much water do you drink daily?',
      'What type of exercise do you do?',
      'Do you have any food allergies or restrictions?',
    ],
    [
      'How many hours do you sleep per night?',
      'What is your occupation?',
      'How would you rate your stress level?',
      'Do you smoke or drink alcohol?',
      'How many days per week can you commit to training?',
      'Do you prefer training at the gym or at home?',
    ],
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = _questionPages.length;
    final double progress = (_currentPage + 1) / totalPages;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalPages,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InfoQuestionsPage(
                  questions: _questionPages[index],
                  onBack: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                );
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
                CustomButton(
                  onPressed: () {
                    if (_currentPage < totalPages - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {}
                  },
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
}
