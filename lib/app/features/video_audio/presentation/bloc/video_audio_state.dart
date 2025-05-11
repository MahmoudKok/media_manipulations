part of 'video_audio_bloc.dart';

class AudioInfo {
  final String path;
  final String? duration;
  final String? resolution;
  final int? fileSize; // Size in bytes

  AudioInfo(
      {required this.path, this.duration, this.resolution, this.fileSize});
}

class VideoAudioState extends Equatable {
  final bool isLoading;
  final AudioInfo? originalVideoInfo;
  final String? audioPath; // Path to the extracted audio
  final String? errorMessage;

  const VideoAudioState({
    this.isLoading = false,
    this.originalVideoInfo,
    this.audioPath,
    this.errorMessage,
  });

  VideoAudioState copyWith({
    bool? isLoading,
    AudioInfo? originalVideoInfo,
    String? audioPath,
    String? errorMessage,
  }) {
    return VideoAudioState(
      isLoading: isLoading ?? this.isLoading,
      originalVideoInfo: originalVideoInfo ?? this.originalVideoInfo,
      audioPath: audioPath ?? this.audioPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, originalVideoInfo, audioPath, errorMessage];
}
