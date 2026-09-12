import 'package:athletica/core/utils/app_colors.dart';
import 'package:athletica/core/utils/app_text_styles.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

/// Picks the gender-matching URL from a male/female pair (demo videos,
/// thumbnails, ...). `gender` is the free-text profile value — anything
/// mentioning female wins (checked first because "female" contains "male");
/// anything else falls back to male. When the preferred version is missing,
/// the other one is used; '' when neither exists. Pure Dart so it stays
/// unit-testable.
String pickGenderedUrl({
  required String maleUrl,
  required String femaleUrl,
  String? gender,
}) {
  final g = (gender ?? '').trim().toLowerCase();
  final wantsFemale = g.contains('female') || g == 'f';
  if (wantsFemale) {
    return femaleUrl.isNotEmpty ? femaleUrl : maleUrl;
  }
  return maleUrl.isNotEmpty ? maleUrl : femaleUrl;
}

/// Picks the demo video matching the user's gender (see [pickGenderedUrl]).
String resolveExerciseVideoUrl({
  required String maleUrl,
  required String femaleUrl,
  String? gender,
}) =>
    pickGenderedUrl(maleUrl: maleUrl, femaleUrl: femaleUrl, gender: gender);

/// Opens [videoUrl] in a dialog player. Shows an explicit message instead
/// when the exercise has no video — never fails silently.
Future<void> showExerciseVideoDialog(
  BuildContext context, {
  required String title,
  required String videoUrl,
  String thumbnailUrl = '',
}) {
  if (videoUrl.isEmpty || Uri.tryParse(videoUrl) == null) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('No video available for this exercise.'),
          backgroundColor: Colors.red,
        ),
      );
    return Future.value();
  }
  return showDialog(
    context: context,
    builder: (_) => _ExerciseVideoDialog(
      title: title,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
    ),
  );
}

class _ExerciseVideoDialog extends StatefulWidget {
  const _ExerciseVideoDialog({
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  final String title;
  final String videoUrl;
  final String thumbnailUrl;

  @override
  State<_ExerciseVideoDialog> createState() => _ExerciseVideoDialogState();
}

class _ExerciseVideoDialogState extends State<_ExerciseVideoDialog> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoController,
                autoPlay: true,
                looping: false,
                allowFullScreen: true,
                // Fullscreen stays portrait instead of forcing landscape.
                deviceOrientationsOnEnterFullScreen: const [
                  DeviceOrientation.portraitUp,
                ],
                deviceOrientationsAfterFullScreen: const [
                  DeviceOrientation.portraitUp,
                ],
                placeholder: _placeholder,
              );
            });
          }).catchError((Object e) {
            if (!mounted) return;
            setState(() => _error = 'Could not load this video.');
          });
  }

  Widget get _placeholder => Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: widget.thumbnailUrl.isNotEmpty
            ? Image.network(
                widget.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const CircularProgressIndicator(),
              )
            : const CircularProgressIndicator(),
      );

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _chewieController;
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        // The 16:9 player can exceed the dialog height (e.g. wide
        // landscape screens), so the content scrolls instead of overflowing.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.semiBold14(context).copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _error != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Text(
                              _error!,
                              style: AppTextStyles.medium14(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : controller != null
                          ? Chewie(controller: controller)
                          : _placeholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
