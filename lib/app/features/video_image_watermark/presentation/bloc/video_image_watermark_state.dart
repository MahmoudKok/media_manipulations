part of 'video_image_watermark_bloc.dart';

class ImageWatermarkedVideoInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  ImageWatermarkedVideoInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoImageWatermarkState extends Equatable {
  final bool isLoading;
  final ImageWatermarkedVideoInfo? originalVideoInfo;
  final String? watermarkedVideoPath; // Path to the watermarked video
  final String? watermarkImagePath; // Path to the selected watermark image
  final String? errorMessage;

  const VideoImageWatermarkState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.watermarkedVideoPath,
    this.watermarkImagePath,
    this.errorMessage,
  });

  VideoImageWatermarkState copyWith({
    bool? isLoading,
    ImageWatermarkedVideoInfo? originalVideoInfo,
    String? watermarkedVideoPath,
    String? watermarkImagePath,
    String? errorMessage,
  }) {
    return VideoImageWatermarkState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      watermarkedVideoPath: watermarkedVideoPath ?? this.watermarkedVideoPath,
      watermarkImagePath: watermarkImagePath ?? this.watermarkImagePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props {
    return [
      isLoading,
      originalVideoInfo,
      watermarkedVideoPath,
      watermarkImagePath,
      errorMessage,
    ];
  }
}
