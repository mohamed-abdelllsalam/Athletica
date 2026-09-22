import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_questions_view_state.dart';
import 'package:flutter/material.dart';

class CheckInQuestionsView extends StatefulWidget {
  const CheckInQuestionsView({
    super.key,
    required this.questions,
    required this.clients,
  });
  final List<CheckInQuestion> questions;
  final List<CheckIn> clients;
  @override
  State<CheckInQuestionsView> createState() => CheckInQuestionsViewState();
}
