part of 'video_merging_bloc.dart';

class MergedVideoInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  MergedVideoInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoMergingState extends Equatable {
  final bool isLoading;
  final List<MergedVideoInfo> selectedVideos;
  final String? mergedVideoPath; // Path to the merged video
  final String? errorMessage;

  const VideoMergingState({
    this.isLoading = false,
    this.selectedVideos = const [],
    this.mergedVideoPath,
    this.errorMessage,
  });

  VideoMergingState copyWith({
    bool? isLoading,
    List<MergedVideoInfo>? selectedVideos,
    String? mergedVideoPath,
    String? errorMessage,
  }) {
    return VideoMergingState(
      isLoading: isLoading ?? this.isLoading,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      mergedVideoPath: mergedVideoPath ?? this.mergedVideoPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, selectedVideos, mergedVideoPath, errorMessage];
}
