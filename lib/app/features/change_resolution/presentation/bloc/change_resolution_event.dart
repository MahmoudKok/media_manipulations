part of 'change_resolution_bloc.dart';

abstract class ChangeResolutionEvent extends Equatable {
  const ChangeResolutionEvent();
}

class VideoSelectedEvent extends ChangeResolutionEvent {
  final String videoPath;

  const VideoSelectedEvent(this.videoPath);

  @override
  List<Object> get props => [videoPath];
}

class ChangeVideoResolutionEvent extends ChangeResolutionEvent {
  final String resolution;

  const ChangeVideoResolutionEvent(this.resolution);

  @override
  List<Object> get props => [resolution];
}

class ResetEvent extends ChangeResolutionEvent {
  @override
  List<Object> get props => [];
}
