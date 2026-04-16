import 'package:athletica/features/coach/complete_profile/presentation/cubits/upload_video_cubit.dart';
import 'package:athletica/features/coach/complete_profile/presentation/views/widgets/coach_upload_video_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachUploadVideoView extends StatelessWidget {
  const CoachUploadVideoView({super.key});

  static const String routeName = 'coach-upload-video';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UploadVideoCubit(),
      child: const CoachUploadVideoViewBody(),
    );
  }
}
