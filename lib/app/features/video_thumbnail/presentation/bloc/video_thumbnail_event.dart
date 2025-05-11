part of 'video_thumbnail_bloc.dart';

class VideoThumbnailEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class PickVideoForThumbnailEvent extends VideoThumbnailEvent {}

class GenerateThumbnailEvent extends VideoThumbnailEvent {
  final double time; // Seconds
  GenerateThumbnailEvent(this.time);
}
