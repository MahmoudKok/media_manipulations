import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
// import 'package:ffmpeg_kit_flutter_full/ffprobe_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/ffmpeg_services/ffmpeg_services.dart';

part 'video_merging_event.dart';
part 'video_merging_state.dart';

class VideoMergingBloc extends Bloc<VideoMergingEvent, VideoMergingState> {
  final ImagePicker _picker = ImagePicker();

  VideoMergingBloc() : super(VideoMergingState()) {
    on<PickVideosForMergingEvent>(_onPickVideos);
    on<MergeVideosEvent>(_onMergeVideos);
  }

  Future<void> _onPickVideos(
      PickVideosForMergingEvent event, Emitter<VideoMergingState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final List<XFile> videos = await _picker.pickMultipleMedia();
      if (videos.isNotEmpty) {
        final List<MergedVideoInfo> videoInfos = [];
        for (var video in videos) {
          final info = await _getVideoInfo(video.path);
          videoInfos.add(info);
        }
        emit(state.copyWith(isLoading: false, selectedVideos: videoInfos));
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: "No videos selected"));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error picking videos: $e"));
    }
  }

  Future<void> _onMergeVideos(
      MergeVideosEvent event, Emitter<VideoMergingState> emit) async {
    if (state.selectedVideos.isEmpty) return;

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final videoPaths = state.selectedVideos.map((info) => info.path).toList();
      final result = await FFmpegService.mergeVideos(inputPaths: videoPaths);

      if (result.isSuccess) {
        final directory = await getExternalStorageDirectory();
        final newPath =
            "${directory!.path}/merged-${DateTime.now().millisecondsSinceEpoch}.mp4";
        await File(result.data!).copy(newPath);
        emit(state.copyWith(isLoading: false, mergedVideoPath: newPath));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: result.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Error merging videos: $e"));
    }
  }

  Future<MergedVideoInfo> _getVideoInfo(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    final duration = info?.getDuration();
    final streams = info?.getStreams();
    final resolution = streams?.isNotEmpty == true
        ? "${streams![0].getWidth()}x${streams[0].getHeight()}"
        : null;
    final fileSize = await File(path).length();
    return MergedVideoInfo(
        path: path,
        duration: duration,
        resolution: resolution,
        fileSize: fileSize);
  }
}
