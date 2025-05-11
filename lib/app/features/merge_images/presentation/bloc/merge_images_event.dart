part of 'merge_images_bloc.dart';

abstract class MergeImagesEvent {}

class SetImagesCountEvent extends MergeImagesEvent {
  final int count;
  SetImagesCountEvent(this.count);
}

class PickImagesEvent extends MergeImagesEvent {}

class MergeImagesToVideoEvent extends MergeImagesEvent {}
