part of 'video_watermark_bloc.dart';

abstract class VideoWatermarkEvent extends Equatable {
  const VideoWatermarkEvent();

  @override
  List<Object> get props => [];
}

class PickVideoForWatermarkEvent extends VideoWatermarkEvent {}

class AddWatermarkEvent extends VideoWatermarkEvent {
  final String watermarkText;
  final String position;
  final String fontColor; // Hex color (e.g., "#FF0000")
  final int fontSize;
  const AddWatermarkEvent(
      this.watermarkText, this.position, this.fontColor, this.fontSize);
}
