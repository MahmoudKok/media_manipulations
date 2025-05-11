part of 'compress_video_bloc.dart';

class VideoCompressionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PickVideoForCompressionEvent extends VideoCompressionEvent {}

class CompressVideoEvent extends VideoCompressionEvent {}
