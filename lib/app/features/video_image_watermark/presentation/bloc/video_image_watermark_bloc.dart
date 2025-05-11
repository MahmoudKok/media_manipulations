import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_image_watermark_event.dart';
part 'video_image_watermark_state.dart';

class VideoImageWatermarkBloc
    extends Bloc<VideoImageWatermarkEvent, VideoImageWatermarkState> {
  final ImagePicker _picker = ImagePicker();

  VideoImageWatermarkBloc() : super(VideoImageWatermarkState()) {
    on<PickVideoForImageWatermarkEvent>(_onPickVideo);
    on<PickImageForWatermarkEvent>(_onPickImage);
    on<AddImageWatermarkEvent>(_onAddImageWatermark);
  }

  Future<void> _onPickVideo(PickVideoForImageWatermarkEvent event,
      Emitter<VideoImageWatermarkState> emit) async {
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

  Future<void> _onPickImage(PickImageForWatermarkEvent event,
      Emitter<VideoImageWatermarkState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(isLoading: false, watermarkImagePath: image.path));
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: "No image selected"));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error picking image: $e"));
    }
  }

  Future<void> _onAddImageWatermark(AddImageWatermarkEvent event,
      Emitter<VideoImageWatermarkState> emit) async {
    if (state.originalVideoInfo == null || state.watermarkImagePath == null)
      return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await FFmpegService.addImageWatermark(
        videoUrl: state.originalVideoInfo!.path,
        imageUrl: event.imagePath,
        position: event.position,
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
          isLoading: false, errorMessage: "Error adding image watermark: $e"));
    }
  }

  Future<ImageWatermarkedVideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length();
    return ImageWatermarkedVideoInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
