part of 'video_image_watermark_bloc.dart';

abstract class VideoImageWatermarkEvent extends Equatable {
  const VideoImageWatermarkEvent();

  @override
  List<Object> get props => [];
}

class PickVideoForImageWatermarkEvent extends VideoImageWatermarkEvent {}

class PickImageForWatermarkEvent extends VideoImageWatermarkEvent {}

class AddImageWatermarkEvent extends VideoImageWatermarkEvent {
  final String imagePath;
  final String position;
  const AddImageWatermarkEvent(this.imagePath, this.position);
}
