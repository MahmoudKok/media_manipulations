import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:media_manipulations/app/core/services/ffmpeg_services/ffmpeg_services.dart';
import 'package:video_player/video_player.dart';
part 'merge_images_event.dart';
part 'merge_images_state.dart';

@Injectable()
class MergeImagesBloc extends Bloc<MergeImagesEvent, MergeImagesState> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController countController = TextEditingController();
  late VideoPlayerController videoController;
  late ChewieController chewieController;

  MergeImagesBloc() : super(MergeImagesState.initial()) {
    on<SetImagesCountEvent>(_onSetImagesCount);
    on<PickImagesEvent>(_onPickImages);
    on<MergeImagesToVideoEvent>(_onMergeImagesToVideo);
  }
  @override
  Future<void> close() {
    videoController.dispose();
    chewieController.dispose();
    return super.close();
  }

  void _onSetImagesCount(
      SetImagesCountEvent event, Emitter<MergeImagesState> emit) {
    emit(state.copyWith(imagesCount: event.count));
  }

  Future<void> _onPickImages(
      PickImagesEvent event, Emitter<MergeImagesState> emit) async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.length >= state.imagesCount) {
      final selectedImages =
          pickedFiles.take(state.imagesCount).map((e) => File(e.path)).toList();

      emit(state.copyWith(selectedImages: selectedImages));
    }
  }

  Future<void> _onMergeImagesToVideo(
      MergeImagesToVideoEvent event, Emitter<MergeImagesState> emit) async {
    if (state.selectedImages.isEmpty) return;

    emit(state.copyWith(isMerging: true));

    final result = await FFmpegService.mergeManyImagesToVideo(
        imagePaths: state.selectedImages.map((i) => i.path).toList(),
        duration: 3);
    log('Result output is $result');
    videoController = VideoPlayerController.file(File(result ?? ''));
    await videoController.initialize();
    chewieController = ChewieController(videoPlayerController: videoController);
    chewieController.setLooping(true);
    chewieController.play();

    emit(state.copyWith(
      isMerging: false,
      videoFile: File(result ?? ""),
    ));
  }
}
