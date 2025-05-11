import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:media_manipulations/app/core/services/ffmpeg_services/ffmpeg_services.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/logger/dev_logger.dart';

part 'final_boss_event.dart';
part 'final_boss_state.dart';

class FinalBossBloc extends Bloc<FinalBossEvent, FinalBossState> {
  final ImagePicker _picker = ImagePicker();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController firstVideo;
  late VideoPlayerController secondVideo;
  late VideoPlayerController finalVideo;

  late ChewieController firstPlayerVideo;
  late ChewieController seconPlayerdVideo;
  late ChewieController finalPlayerdVideo;

  FinalBossBloc() : super(FinalBossState.init()) {
    on<PickFirstImage>(onPickFirstImage);
    on<PickSecondImage>(onPickSecondImage);
    on<PickFirstVideo>(onPickFirstVideo);
    on<PickSecondVideo>(onPickSecondVideo);
    on<PlayExtractedAudio>(onPlayExtractedAudio);
    on<FireButtonPressed>(onFireButtonPressed);
    on<ExtractAudioFromVideo>(onExtractAudioFromVideo);
  }
  Future<void> onPickFirstImage(
      PickFirstImage event, Emitter<FinalBossState> emit) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(firstImage: File(image.path)));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> onExtractAudioFromVideo(
      ExtractAudioFromVideo event, Emitter<FinalBossState> emit) async {
    try {
      emit(state.copyWith(extratAudioStste: ScreenState.loading));
      final result =
          await FFmpegService.extractAudio(videoUrl: state.firstVideo!.path);
      if (result.isSuccess) {
        emit(state.copyWith(
          extractedAudioPath: result.data,
          isProcessing: false,
          extratAudioStste: ScreenState.succes,
        ));
      }
    } catch (e) {
      // Handle error
      log(e.toString());
    }
  }

  Future<void> onPickSecondImage(
      PickSecondImage event, Emitter<FinalBossState> emit) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        emit(state.copyWith(secondImage: File(image.path)));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> onPickFirstVideo(
      PickFirstVideo event, Emitter<FinalBossState> emit) async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      firstVideo = VideoPlayerController.file(File(video!.path));
      await firstVideo.initialize();
      firstPlayerVideo = ChewieController(videoPlayerController: firstVideo);
      await firstPlayerVideo.setLooping(true);
      await firstPlayerVideo.play();
      emit(state.copyWith(firstVideo: File(video.path)));
      // emit(state.copyWith(firstVideo: File(video.path), isProcessing: true));
      // // Extract audio from first video
      // // final info = await VideoCompress.getMediaInfo(state.firstVideo!.path);
      // final result =
      //     await FFmpegService.extractAudio(videoUrl: state.firstVideo!.path);
      // log('Result with data ${result.data}');

      // if (result.isSuccess) {
      //   log('Succses with data ${result.data}');
      //   emit(state.copyWith(
      //     extractedAudioPath: result.data,
      //     isProcessing: false,
      //   ));
      //   add(PlayExtractedAudio());
      // }
      // if (info.path != null) {
      //   // Assuming video_compress stores extracted audio in a temporary file
      //   final tempAudioPath = '${info.path}.mp3';
      //   emit(state.copyWith(
      //     extractedAudioPath: tempAudioPath,
      //     isProcessing: false,
      //   ));
      //   add(PlayExtractedAudio());
      // }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> onPickSecondVideo(
      PickSecondVideo event, Emitter<FinalBossState> emit) async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        secondVideo = VideoPlayerController.file(File(video.path));
        await secondVideo.initialize();
        seconPlayerdVideo =
            ChewieController(videoPlayerController: secondVideo);
        await seconPlayerdVideo.setLooping(true);
        await seconPlayerdVideo.play();
        emit(state.copyWith(secondVideo: File(video.path)));
        emit(state.copyWith(secondVideo: File(video.path)));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> onPlayExtractedAudio(
      PlayExtractedAudio event, Emitter<FinalBossState> emit) async {
    if (state.extractedAudioPath != null) {
      try {
        emit(state.copyWith(isAudioPlaying: true));
        await _audioPlayer.play(DeviceFileSource(state.extractedAudioPath!));
      } catch (e) {
        emit(state.copyWith(isAudioPlaying: false));
      }
    }
  }

  Future<void> onFireButtonPressed(
      FireButtonPressed event, Emitter<FinalBossState> emit) async {
    if (state.firstVideo != null) {
      try {
        emit(state.copyWith(finalResultStste: ScreenState.loading));
        log('Start procces');
        final imagesVideo =
            await FFmpegService.mergeManyImagesToVideo(imagePaths: [
          state.firstImage!.path,
          state.secondImage!.path,
          // state.firstImage!.path,
        ], duration: 5);
        log('Merge videos Done');
        log('Images to video Done');
        // finalVideo = VideoPlayerController.file(File(imagesVideo));
        // await finalVideo.initialize();
        // finalPlayerdVideo = ChewieController(videoPlayerController: finalVideo);
        // await finalPlayerdVideo.setLooping(true);
        // await finalPlayerdVideo.play();
        // emit(state.copyWith(
        //   finalResult: File(imagesVideo),
        //   finalResultStste: ScreenState.succes,
        // ));
        // return;

        log(imagesVideo);
        final mutedVideo =
            await FFmpegService.removeAudiosFromVideo(state.secondVideo!.path);
        log('Mute video Done');

        final mergedVideos = await FFmpegService.mergeVideos(
            inputPaths: [mutedVideo, imagesVideo]);
        if (mergedVideos.isSuccess) {
          log('Merge videos Done');
          // log('Images to video Done');
          // finalVideo = VideoPlayerController.file(File(mergedVideos.data!));
          // await finalVideo.initialize();
          // finalPlayerdVideo =
          //     ChewieController(videoPlayerController: finalVideo);
          // await finalPlayerdVideo.setLooping(true);
          // await finalPlayerdVideo.play();
          // emit(state.copyWith(
          //   finalResult: File(mergedVideos.data!),
          //   finalResultStste: ScreenState.succes,
          // ));
          // return;
          final result = await FFmpegService.mergeVideoWithAudio(
              videoUrl: mergedVideos.data!,
              audioUrl: state.extractedAudioPath!);
          if (result.isSuccess) {
            log('Final Done');
            finalVideo = VideoPlayerController.file(File(result.data!));
            await finalVideo.initialize();
            finalPlayerdVideo =
                ChewieController(videoPlayerController: finalVideo);
            await finalPlayerdVideo.setLooping(true);
            await finalPlayerdVideo.play();
            emit(state.copyWith(
              finalResult: File(result.data!),
              finalResultStste: ScreenState.succes,
            ));
          }
        } else {
          Dev.logError('Merge videos failed ${mergedVideos.message}');
        }
      } catch (e) {
        emit(state.copyWith(isProcessing: false));
      }
    }
  }
}
