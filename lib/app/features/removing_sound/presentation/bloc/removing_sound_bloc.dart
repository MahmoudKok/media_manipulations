import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:media_manipulations/app/core/services/ffmpeg_services/ffmpeg_services.dart';

part 'removing_sound_event.dart';
part 'removing_sound_state.dart';

class RemovingSoundBloc extends Bloc<RemovingSoundEvent, RemovingSoundState> {
  RemovingSoundBloc() : super(const RemovingSoundState()) {
    on<VideoSelectedEvent>(_onVideoSelected);
    on<RemoveSoundEvent>(_onRemoveSound);
    on<ResetEvent>(_onReset);
    on<AnotherVideoSelectedEvent>(_onAnotherVideoSelected);
    on<MergeAudioEvent>(_onMergeAudio);
  }

  void _onVideoSelected(
      VideoSelectedEvent event, Emitter<RemovingSoundState> emit) {
    emit(state.copyWith(
      originalVideoPath: event.videoPath,
      processedVideoPath: null,
      anotherVideoPath: null,
      mergedVideoPath: null,
      isProcessing: false,
      errorMessage: null,
    ));
  }

  Future<void> _onRemoveSound(
      RemoveSoundEvent event, Emitter<RemovingSoundState> emit) async {
    if (state.originalVideoPath == null || state.isProcessed) {
      return;
    }
    emit(state.copyWith(isProcessing: true, errorMessage: null));
    try {
      final inputPath = state.originalVideoPath!;
      final outputPath =
          await FFmpegService.removeAudioFromVideo(videoUrl: inputPath);
      emit(state.copyWith(
        processedVideoPath: outputPath.data,
        isProcessing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to remove sound: $e',
      ));
    }
  }

  void _onReset(ResetEvent event, Emitter<RemovingSoundState> emit) {
    emit(const RemovingSoundState());
  }

  void _onAnotherVideoSelected(
      AnotherVideoSelectedEvent event, Emitter<RemovingSoundState> emit) {
    emit(state.copyWith(
      anotherVideoPath: event.videoPath,
      mergedVideoPath: null,
      isProcessing: false,
      errorMessage: null,
    ));
  }

  Future<void> _onMergeAudio(
      MergeAudioEvent event, Emitter<RemovingSoundState> emit) async {
    if (state.processedVideoPath == null ||
        state.anotherVideoPath == null ||
        state.isMerged) {
      return;
    }
    emit(state.copyWith(isProcessing: true, errorMessage: null));
    try {
      final audioPath =
          await FFmpegService.extractAudio(videoUrl: state.anotherVideoPath!);
      final mergedVideoPath = await FFmpegService.mergeVideoWithAudio(
        videoUrl: state.processedVideoPath!,
        audioUrl: audioPath.data!,
      );
      emit(state.copyWith(
        mergedVideoPath: mergedVideoPath.data,
        isProcessing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMessage: 'Failed to merge audio: $e',
      ));
    }
  }
}
