part of 'video_trimming_bloc.dart';

class TrimmedVideoInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  TrimmedVideoInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoTrimmingState extends Equatable {
  final bool isLoading;
  final TrimmedVideoInfo? originalVideoInfo;
  final TrimmedVideoInfo? trimmedVideoInfo;
  final String? errorMessage;

  const VideoTrimmingState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.trimmedVideoInfo,
    this.errorMessage,
  });

  VideoTrimmingState copyWith({
    bool? isLoading,
    TrimmedVideoInfo? originalVideoInfo,
    TrimmedVideoInfo? trimmedVideoInfo,
    String? errorMessage,
  }) {
    return VideoTrimmingState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      trimmedVideoInfo: trimmedVideoInfo ?? this.trimmedVideoInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, trimmedVideoInfo, errorMessage];
}
