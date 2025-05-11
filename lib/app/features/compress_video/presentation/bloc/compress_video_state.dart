part of 'compress_video_bloc.dart';

class CompressedVideoInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  CompressedVideoInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoCompressionState extends Equatable {
  final bool isLoading;
  final CompressedVideoInfo? originalVideoInfo; // Now uses CompressedVideoInfo
  final CompressedVideoInfo? compressedVideoInfo;
  final String? errorMessage;

  const VideoCompressionState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.compressedVideoInfo,
    this.errorMessage,
  });

  VideoCompressionState copyWith({
    bool? isLoading,
    CompressedVideoInfo? originalVideoInfo,
    CompressedVideoInfo? compressedVideoInfo,
    String? errorMessage,
  }) {
    return VideoCompressionState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      compressedVideoInfo: compressedVideoInfo ?? this.compressedVideoInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, compressedVideoInfo, errorMessage];
}
