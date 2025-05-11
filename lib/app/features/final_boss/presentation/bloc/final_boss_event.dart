part of 'final_boss_bloc.dart';

abstract class FinalBossEvent extends Equatable {
  const FinalBossEvent();

  @override
  List<Object?> get props => [];
}

class PickFirstImage extends FinalBossEvent {}

class PickSecondImage extends FinalBossEvent {}

class PickFirstVideo extends FinalBossEvent {}

class PickSecondVideo extends FinalBossEvent {}

class ExtractAudioFromVideo extends FinalBossEvent {}

class PlayExtractedAudio extends FinalBossEvent {}

class FireButtonPressed extends FinalBossEvent {}
