part of 'video_watermark_bloc.dart';

class WatermarkedVideoInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  WatermarkedVideoInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoWatermarkState extends Equatable {
  final bool isLoading;
  final WatermarkedVideoInfo? originalVideoInfo;
  final String? watermarkedVideoPath; // Path to the watermarked video
  final String? errorMessage;

  const VideoWatermarkState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.watermarkedVideoPath,
    this.errorMessage,
  });

  VideoWatermarkState copyWith({
    bool? isLoading,
    WatermarkedVideoInfo? originalVideoInfo,
    String? watermarkedVideoPath,
    String? errorMessage,
  }) {
    return VideoWatermarkState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      watermarkedVideoPath: watermarkedVideoPath ?? this.watermarkedVideoPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, watermarkedVideoPath, errorMessage];
}
