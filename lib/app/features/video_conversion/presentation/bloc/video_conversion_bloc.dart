import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_conversion_event.dart';
part 'video_conversion_state.dart';

class VideoConversionBloc
    extends Bloc<VideoConversionEvent, VideoConversionState> {
  final ImagePicker _picker = ImagePicker();

  VideoConversionBloc() : super(VideoConversionState()) {
    on<PickVideoEvent>(_onPickVideo);
    on<ConvertVideoEvent>(_onConvertVideo);
  }

  Future<void> _onPickVideo(
      PickVideoEvent event, Emitter<VideoConversionState> emit) async {
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

  Future<void> _onConvertVideo(
      ConvertVideoEvent event, Emitter<VideoConversionState> emit) async {
    if (state.originalVideoInfo == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.convertVideo(
        videoUrl: state.originalVideoInfo!.path,
        newFormat: event.newFormat,
      );

      if (result.isSuccess) {
        // Copy the converted file to a public directory
        final directory =
            await getExternalStorageDirectory(); // e.g., /storage/emulated/0/Android/data/...
        final newPath =
            "${directory!.path}/converted-${DateTime.now().millisecondsSinceEpoch}.avi";
        await File(result.data!).copy(newPath); // Copy to new location

        final convertedInfo = await _getVideoInfo(newPath); // Use new path
        emit(state.copyWith(
            isLoading: false, convertedVideoInfo: convertedInfo));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error converting video: $e"));
    }
  }

  Future<VideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    return VideoInfo(path: path, duration: duration, resolution: resolution);
  }
}
