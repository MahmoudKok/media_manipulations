import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'compress_video_event.dart';
part 'compress_video_state.dart';

class VideoCompressionBloc
    extends Bloc<VideoCompressionEvent, VideoCompressionState> {
  final ImagePicker _picker = ImagePicker();

  VideoCompressionBloc() : super(VideoCompressionState()) {
    on<PickVideoForCompressionEvent>(_onPickVideo);
    on<CompressVideoEvent>(_onCompressVideo);
  }

  Future<void> _onPickVideo(PickVideoForCompressionEvent event,
      Emitter<VideoCompressionState> emit) async {
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

  Future<void> _onCompressVideo(
      CompressVideoEvent event, Emitter<VideoCompressionState> emit) async {
    if (state.originalVideoInfo == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.compressVideo(
        videoUrl: state.originalVideoInfo!.path,
        crf: 40,
        audioCrf: 64,
      );

      if (result.isSuccess) {
        final directory = await getExternalStorageDirectory();
        final newPath =
            "${directory!.path}/compressed-${DateTime.now().millisecondsSinceEpoch}.mp4";
        await File(result.data!).copy(newPath);
        final compressedInfo = await _getVideoInfo(newPath);
        emit(state.copyWith(
            isLoading: false, compressedVideoInfo: compressedInfo));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error compressing video: $e"));
    }
  }

  Future<CompressedVideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length(); // Get file size in bytes
    return CompressedVideoInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
