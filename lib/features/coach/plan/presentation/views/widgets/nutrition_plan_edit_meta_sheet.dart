import 'nutrition_plan_meta_form.dart';
import 'package:flutter/material.dart';

class NutritionPlanEditMetaSheet extends StatefulWidget {
  const NutritionPlanEditMetaSheet({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.onSave,
  });

  final String initialName;
  final String initialDescription;
  final Future<String?> Function({
    required String title,
    required String description,
  })
  onSave;

  @override
  State<NutritionPlanEditMetaSheet> createState() =>
      _NutritionPlanEditMetaSheetState();
}

class _NutritionPlanEditMetaSheetState
    extends State<NutritionPlanEditMetaSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialDescription);
  bool _nameHasError = false;
  bool _descriptionHasError = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final nameError = name.isEmpty;
    final descriptionError = description.isEmpty;
    if (nameError || descriptionError) {
      setState(() {
        _nameHasError = nameError;
        _descriptionHasError = descriptionError;
      });
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final error = await widget.onSave(title: name, description: description);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = false;
      _errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CoachNutritionPlanMetaForm(
      nameController: _nameController,
      descriptionController: _descriptionController,
      nameHasError: _nameHasError,
      descriptionHasError: _descriptionHasError,
      saving: _saving,
      errorMessage: _errorMessage,
      bottomInset: MediaQuery.of(context).viewInsets.bottom,
      onSave: _save,
      onNameChanged: (_) {
        if (_nameHasError && _nameController.text.trim().isNotEmpty) {
          setState(() => _nameHasError = false);
        }
      },
      onDescriptionChanged: (_) {
        if (_descriptionHasError &&
            _descriptionController.text.trim().isNotEmpty) {
          setState(() => _descriptionHasError = false);
        }
      },
      onDescriptionSubmitted: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
