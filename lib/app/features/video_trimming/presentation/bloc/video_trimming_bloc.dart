import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_trimming_event.dart';
part 'video_trimming_state.dart';

class VideoTrimmingBloc extends Bloc<VideoTrimmingEvent, VideoTrimmingState> {
  final ImagePicker _picker = ImagePicker();

  VideoTrimmingBloc() : super(VideoTrimmingState()) {
    on<PickVideoForTrimmingEvent>(_onPickVideo);
    on<TrimVideoEvent>(_onTrimVideo);
  }

  Future<void> _onPickVideo(
      PickVideoForTrimmingEvent event, Emitter<VideoTrimmingState> emit) async {
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

  Future<void> _onTrimVideo(
      TrimVideoEvent event, Emitter<VideoTrimmingState> emit) async {
    if (state.originalVideoInfo == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.trimVideo(
        videoUrl: state.originalVideoInfo!.path,
        startTime: event.startTime.toString(),
        endTime: event.endTime.toString(),
      );

      if (result.isSuccess) {
        final directory = await getExternalStorageDirectory();
        final newPath =
            "${directory!.path}/trimmed-${DateTime.now().millisecondsSinceEpoch}.mp4";
        await File(result.data!).copy(newPath);
        final trimmedInfo = await _getVideoInfo(newPath);
        emit(state.copyWith(isLoading: false, trimmedVideoInfo: trimmedInfo));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error trimming video: $e"));
    }
  }

  Future<TrimmedVideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length();
    return TrimmedVideoInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
