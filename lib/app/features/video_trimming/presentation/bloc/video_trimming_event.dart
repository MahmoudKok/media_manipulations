part of 'video_trimming_bloc.dart';

abstract class VideoTrimmingEvent extends Equatable {
  const VideoTrimmingEvent();

  @override
  List<Object> get props => [];
}

class PickVideoForTrimmingEvent extends VideoTrimmingEvent {}

class TrimVideoEvent extends VideoTrimmingEvent {
  final double startTime; // Seconds
  final double endTime; // Seconds
  const TrimVideoEvent(this.startTime, this.endTime);
}
