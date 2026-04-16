sealed class UploadVideoState {}

final class UploadVideoInitial extends UploadVideoState {}

final class UploadVideoLoading extends UploadVideoState {}

final class UploadVideoSuccess extends UploadVideoState {
  UploadVideoSuccess({required this.videoPath});
  final String videoPath;
}

final class UploadVideoFailure extends UploadVideoState {}
