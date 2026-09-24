import 'dart:typed_data';

import 'package:athletica/core/di/injection_container.dart';
import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:athletica/core/utils/pdf_opener.dart' show resolvePdfUrl;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _bytes;
  bool _isLoading = true;
  String? _errorMessage;
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = resolvePdfUrl(widget.url);
    if (_resolvedUrl == null) {
      _isLoading = false;
      _errorMessage = 'The PDF could not be opened. Please try again.';
    } else {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    final url = _resolvedUrl;
    if (url == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = sl.isRegistered<Dio>() ? sl<Dio>() : Dio();
      // If we fell back to a fresh Dio, try to use the ApiClient's dio via get_it
      // The registered Dio already has auth interceptors.
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'The PDF is empty or could not be downloaded.';
        });
        return;
      }
      if (!mounted) return;
      setState(() {
        _bytes = Uint8List.fromList(data);
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final message = status == 401
          ? 'You are not authorized to view this PDF. Please sign in again.'
          : status == 404
              ? 'The PDF could not be found.'
              : 'The PDF could not be downloaded. Please check your connection.';
      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'The PDF could not be opened. Please try again.';
      });
    }
  }

  Future<void> _openExternally() async {
    final url = _resolvedUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The PDF could not be opened externally.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.title?.trim().isNotEmpty == true
        ? widget.title!.trim()
        : 'Certificate';

    return Scaffold(
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
          displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bold20(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (_resolvedUrl != null)
            IconButton(
              tooltip: 'Open externally',
              icon: const Icon(
                Icons.open_in_new,
                color: AppColors.textPrimary,
              ),
              onPressed: _openExternally,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf_outlined,
                size: 48.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.medium14(
                  context,
                ).copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.semiBold14(
                        context,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton(
                    onPressed: _openExternally,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Open externally',
                      style: AppTextStyles.medium14(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    final bytes = _bytes;
    if (bytes == null) {
      return Center(
        child: Text(
          'Unable to load PDF.',
          style: AppTextStyles.medium14(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return SfPdfViewer.memory(
      bytes,
      canShowPaginationDialog: true,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
    );
  }
}
