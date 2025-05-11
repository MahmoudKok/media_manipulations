import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_watermark_event.dart';
part 'video_watermark_state.dart';

class VideoWatermarkBloc
    extends Bloc<VideoWatermarkEvent, VideoWatermarkState> {
  final ImagePicker _picker = ImagePicker();

  VideoWatermarkBloc() : super(VideoWatermarkState()) {
    on<PickVideoForWatermarkEvent>(_onPickVideo);
    on<AddWatermarkEvent>(_onAddWatermark);
  }

  Future<void> _onPickVideo(PickVideoForWatermarkEvent event,
      Emitter<VideoWatermarkState> emit) async {
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

  Future<void> _onAddWatermark(
      AddWatermarkEvent event, Emitter<VideoWatermarkState> emit) async {
    if (state.originalVideoInfo == null) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.addWatermark(
        videoUrl: state.originalVideoInfo!.path,
        watermarkText: event.watermarkText,
        position: event.position,
        fontColor: event.fontColor,
        fontSize: event.fontSize,
      );

      if (result.isSuccess) {
        final directory = await getExternalStorageDirectory();
        final newPath =
            "${directory!.path}/watermarked-${DateTime.now().millisecondsSinceEpoch}.mp4";
        await File(result.data!).copy(newPath);
        emit(state.copyWith(isLoading: false, watermarkedVideoPath: newPath));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error adding watermark: $e"));
    }
  }

  Future<WatermarkedVideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length();
    return WatermarkedVideoInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
