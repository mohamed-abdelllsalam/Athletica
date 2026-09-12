import 'package:athletica/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseThumbnail extends StatelessWidget {
  const ExerciseThumbnail({super.key, this.size = 80, this.thumbnailUrl = ''});

  final double size;

  /// Backend thumbnail (`thumbnails.male/female`); empty keeps the
  /// play-icon placeholder.
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: thumbnailUrl.isEmpty
          ? Center(
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 18.sp),
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) =>
                      progress == null
                          ? child
                          : const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                  errorBuilder: (_, _, _) => Center(
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 4.r,
                  bottom: 4.r,
                  child: Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
