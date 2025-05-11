part of 'video_audio_bloc.dart';

abstract class VideoAudioEvent extends Equatable {
  const VideoAudioEvent();

  @override
  List<Object> get props => [];
}

class PickVideoForAudioEvent extends VideoAudioEvent {}

class ExtractAudioEvent extends VideoAudioEvent {}
