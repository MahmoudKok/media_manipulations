part of 'removing_sound_bloc.dart';

abstract class RemovingSoundEvent extends Equatable {
  const RemovingSoundEvent();
}

class VideoSelectedEvent extends RemovingSoundEvent {
  final String videoPath;

  const VideoSelectedEvent(this.videoPath);

  @override
  List<Object> get props => [videoPath];
}

class RemoveSoundEvent extends RemovingSoundEvent {
  @override
  List<Object> get props => [];
}

class ResetEvent extends RemovingSoundEvent {
  @override
  List<Object> get props => [];
}

class AnotherVideoSelectedEvent extends RemovingSoundEvent {
  final String videoPath;

  const AnotherVideoSelectedEvent(this.videoPath);

  @override
  List<Object> get props => [videoPath];
}

class MergeAudioEvent extends RemovingSoundEvent {
  @override
  List<Object> get props => [];
}
