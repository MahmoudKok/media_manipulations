part of 'video_conversion_bloc.dart';

class VideoInfo {
  final String path;
  final String? duration;
  final String? resolution;

  VideoInfo({required this.path, this.duration, this.resolution});
}

class VideoConversionState extends Equatable {
  final bool isLoading;
  final VideoInfo? originalVideoInfo;
  final VideoInfo? convertedVideoInfo;
  final String? errorMessage;

  const VideoConversionState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.convertedVideoInfo,
    this.errorMessage,
  });

  VideoConversionState copyWith({
    bool? isLoading,
    VideoInfo? originalVideoInfo,
    VideoInfo? convertedVideoInfo,
    String? errorMessage,
  }) {
    return VideoConversionState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      convertedVideoInfo: convertedVideoInfo ?? this.convertedVideoInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, convertedVideoInfo, errorMessage];
}
