part of 'video_merging_bloc.dart';

abstract class VideoMergingEvent extends Equatable {
  const VideoMergingEvent();

  @override
  List<Object> get props => [];
}

class PickVideosForMergingEvent extends VideoMergingEvent {}

class MergeVideosEvent extends VideoMergingEvent {}
