import 'package:athletica/features/check_ins/domain/entities/check_in.dart';
import 'package:athletica/features/check_ins/presentation/views/check_in_response_view_state.dart';
import 'package:flutter/material.dart';

class CheckInResponseView extends StatefulWidget {
  const CheckInResponseView({
    super.key,
    required this.entry,
    required this.questions,
    required this.coachResponse,
    this.embedded = false,
  });
  final CheckIn entry;
  final List<CheckInQuestion> questions;
  final bool coachResponse;
  final bool embedded;
  @override
  State<CheckInResponseView> createState() => CheckInResponseViewState();
}
