import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_audio_event.dart';
part 'video_audio_state.dart';

class VideoAudioBloc extends Bloc<VideoAudioEvent, VideoAudioState> {
  final ImagePicker _picker = ImagePicker();

  VideoAudioBloc() : super(VideoAudioState()) {
    on<PickVideoForAudioEvent>(_onPickVideo);
    on<ExtractAudioEvent>(_onExtractAudio);
  }

  Future<void> _onPickVideo(
      PickVideoForAudioEvent event, Emitter<VideoAudioState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final info = await _getVideoInfo(video.path);
        emit(state.copyWith(isLoading: false, originalVideoInfo: info));
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: "No video selected"));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error picking video: $e"));
    }
  }

  Future<void> _onExtractAudio(
      ExtractAudioEvent event, Emitter<VideoAudioState> emit) async {
    if (state.originalVideoInfo == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.extractAudio(
        videoUrl: state.originalVideoInfo!.path,
      );

      if (result.isSuccess) {
        final directory = await getExternalStorageDirectory();
        final newPath =
            "${directory!.path}/audio-${DateTime.now().millisecondsSinceEpoch}.mp3";
        await File(result.data!).copy(newPath);
        emit(state.copyWith(isLoading: false, audioPath: newPath));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error extracting audio: $e"));
    }
  }

  Future<AudioInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length();
    return AudioInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
