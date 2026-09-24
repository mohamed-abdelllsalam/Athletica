import 'dart:io';
import 'dart:typed_data';

import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/cubits/add_certificate_state.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_certificate_form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachAddCertificateViewBody extends StatefulWidget {
  const CoachAddCertificateViewBody({super.key});

  @override
  State<CoachAddCertificateViewBody> createState() =>
      _CoachAddCertificateViewBodyState();
}

class _CoachAddCertificateViewBodyState
    extends State<CoachAddCertificateViewBody> {
  final _titleController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  String? _titleError;
  String? _fileError;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (!mounted || pickedFile == null) return;

      final name = pickedFile.name;
      // Validate extension via file name (more reliable than path on content URIs).
      if (!name.toLowerCase().endsWith('.pdf')) {
        setState(() => _fileError = 'Only PDF files are allowed.');
        return;
      }

      // Prefer PlatformFile.length() (no I/O) then fallback to reading bytes or File.
      int? size = await pickedFile.length();
      Uint8List? cachedBytes;
      if (size == null) {
        try {
          cachedBytes = await pickedFile.readAsBytes();
          size = cachedBytes.length;
        } catch (_) {
          size = null;
        }
      }
      // Fallback to File length if still unknown and path is available.
      if (size == null) {
        final fallbackPath = pickedFile.path;
        if (fallbackPath != null && fallbackPath.trim().isNotEmpty) {
          try {
            size = await File(fallbackPath).length();
          } catch (_) {}
        }
      }
      if (size == null) {
        setState(() => _fileError = 'The selected PDF could not be read.');
        return;
      }
      if (!mounted) return;
      if (size <= 0) {
        setState(() => _fileError = 'The selected PDF is empty.');
        return;
      }
      if (size > 10 * 1024 * 1024) {
        setState(() => _fileError = 'PDF files must be 10 MB or smaller.');
        return;
      }

      // Materialize a File for the upload layer (which expects dart:io File).
      // On platforms where path is null (web, Android content://), write bytes
      // to a temp file.
      File file;
      final path = pickedFile.path;
      if (path != null && path.trim().isNotEmpty) {
        if (!path.toLowerCase().endsWith('.pdf')) {
          setState(() => _fileError = 'Only PDF files are allowed.');
          return;
        }
        file = File(path);
      } else {
        cachedBytes ??= await pickedFile.readAsBytes();
        final tempDir = Directory.systemTemp;
        final sanitized = name.replaceAll(RegExp(r'[^\w\-.]+'), '_');
        final tempPath =
            '${tempDir.path}${Platform.pathSeparator}${DateTime.now().millisecondsSinceEpoch}_$sanitized';
        file = File(tempPath);
        await file.writeAsBytes(cachedBytes, flush: true);
      }

      if (!mounted) return;
      setState(() {
        _selectedFile = file;
        _selectedFileName = name;
        _selectedFileSize = size;
        _fileError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _fileError = 'The PDF could not be selected.');
    }
  }

  void _saveCertificate() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Certificate title is required.');
      return;
    }
    if (_selectedFile == null) {
      setState(() => _fileError = 'Please select a PDF certificate.');
      return;
    }

    setState(() {
      _titleError = null;
      _fileError = null;
    });
    context.read<AddCertificateCubit>().saveCertificate(
      title: title,
      file: _selectedFile!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCertificateCubit, AddCertificateState>(
      listener: (context, state) {
        if (state is AddCertificateSuccess) {
          Navigator.of(context).pop(state.achievement);
        } else if (state is AddCertificateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryAppColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryAppColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Add Certificate',
            style: AppTextStyles.bold20(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: CoachCertificateForm(
              titleController: _titleController,
              onUpload: _pickPdf,
              selectedFileName: _selectedFileName,
              selectedFileSize: _selectedFileSize,
              titleError: _titleError,
              fileError: _fileError,
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
          child: BlocBuilder<AddCertificateCubit, AddCertificateState>(
            builder: (context, state) {
              final isSaving = state is AddCertificateSaving;
              return SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveCertificate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    disabledBackgroundColor: AppColors.buttonColor.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTextStyles.semiBold15(
                            context,
                          ).copyWith(color: AppColors.textPrimary),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
