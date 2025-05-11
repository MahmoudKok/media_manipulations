part of 'video_thumbnail_bloc.dart';

class ThumbnailInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  ThumbnailInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoThumbnailState extends Equatable {
  final bool isLoading;
  final ThumbnailInfo? originalVideoInfo;
  final String? thumbnailPath; // Path to the generated image
  final String? errorMessage;

  const VideoThumbnailState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.thumbnailPath,
    this.errorMessage,
  });

  VideoThumbnailState copyWith({
    bool? isLoading,
    ThumbnailInfo? originalVideoInfo,
    String? thumbnailPath,
    String? errorMessage,
  }) {
    return VideoThumbnailState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, thumbnailPath, errorMessage];
}
