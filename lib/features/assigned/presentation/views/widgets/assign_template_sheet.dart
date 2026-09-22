import 'package:athletica/features/assigned/presentation/cubits/assigned_cubit.dart';
import 'package:athletica/features/assigned/presentation/views/widgets/assign_template_sheet_state.dart';
import 'package:flutter/material.dart';

class AssignTemplateSheet extends StatefulWidget {
  const AssignTemplateSheet({super.key, required this.type});

  final AssignType type;

  @override
  State<AssignTemplateSheet> createState() => AssignTemplateSheetState();
}
