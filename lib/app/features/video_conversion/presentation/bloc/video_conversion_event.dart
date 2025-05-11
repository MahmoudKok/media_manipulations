part of 'video_conversion_bloc.dart';

class VideoConversionEvent extends Equatable {
  @override
  //
  List<Object?> get props => [];
}

class PickVideoEvent extends VideoConversionEvent {}

class ConvertVideoEvent extends VideoConversionEvent {
  final String newFormat;
  ConvertVideoEvent(this.newFormat);
}
