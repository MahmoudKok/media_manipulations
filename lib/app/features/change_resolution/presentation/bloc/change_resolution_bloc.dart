import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:media_manipulations/app/core/services/ffmpeg_services/ffmpeg_services.dart';

part 'change_resolution_event.dart';
part 'change_resolution_state.dart';

class ChangeResolutionBloc
    extends Bloc<ChangeResolutionEvent, ChangeResolutionState> {
  ChangeResolutionBloc() : super(const ChangeResolutionState()) {
    on<VideoSelectedEvent>(_onVideoSelected);
    on<ChangeVideoResolutionEvent>(_onChangeResolution);
    on<ResetEvent>(_onReset);
  }

  void _onVideoSelected(
      VideoSelectedEvent event, Emitter<ChangeResolutionState> emit) {
    emit(state.copyWith(
      originalVideoPath: event.videoPath,
      processedVideoPath: null,
      isProcessing: false,
      errorMessage: null,
    ));
  }

  Future<void> _onChangeResolution(ChangeVideoResolutionEvent event,
      Emitter<ChangeResolutionState> emit) async {
    if (state.originalVideoPath == null || state.isProcessed) {
      return;
    }
    emit(state.copyWith(isProcessing: true, errorMessage: null));
    try {
      final inputPath = state.originalVideoPath!;
      final outputPath = await FFmpegService.changeVideoQuality(
          videoPath: inputPath, quality: 'low');
      emit(state.copyWith(
        processedVideoPath: outputPath.data,
        isProcessing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to change resolution: $e',
      ));
    }
  }

  void _onReset(ResetEvent event, Emitter<ChangeResolutionState> emit) {
    emit(const ChangeResolutionState());
  }

  // Future<String> _changeResolution(String inputPath, String resolution) async {
  //   final outputPath =
  //       '${Directory.systemTemp.path}/resized_${DateTime.now().millisecondsSinceEpoch}.mp4';
  //   String scaleFilter;
  //   switch (resolution) {
  //     case '480p':
  //       scaleFilter = 'scale=854:480';
  //       break;
  //     case '720p':
  //       scaleFilter = 'scale=1280:720';
  //       break;
  //     case '1080p':
  //       scaleFilter = 'scale=1920:1080';
  //       break;
  //     default:
  //       throw Exception('Unsupported resolution');
  //   }
  //   final session = await FFmpegService.changeVideoResolutionByPreset(
  //       videoPath: inputPath, preset: '240');
  //   final returnCode = await session.getReturnCode();
  //   if (returnCode.isValueSuccess()) {
  //     return outputPath;
  //   } else {
  //     throw Exception('FFmpeg failed to change resolution');
  //   }
  // }
}
