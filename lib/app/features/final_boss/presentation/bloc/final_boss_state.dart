part of 'final_boss_bloc.dart';

class FinalBossState extends Equatable {
  final File? firstImage;
  final File? secondImage;
  final File? firstVideo;
  final File? secondVideo;
  final ScreenState extratAudioStste;
  final String? extractedAudioPath;
  final bool isProcessing;
  final bool isAudioPlaying;
  final ScreenState finalResultStste;
  final File? finalResult;

  static FinalBossState init() {
    return FinalBossState(
        extratAudioStste: ScreenState.init, finalResultStste: ScreenState.init);
  }

  const FinalBossState({
    this.firstImage,
    this.secondImage,
    this.firstVideo,
    this.secondVideo,
    required this.extratAudioStste,
    this.extractedAudioPath,
    this.isProcessing = false,
    this.isAudioPlaying = false,
    required this.finalResultStste,
    this.finalResult,
  });

  FinalBossState copyWith({
    File? firstImage,
    File? secondImage,
    File? firstVideo,
    File? secondVideo,
    ScreenState? extratAudioStste,
    String? extractedAudioPath,
    bool? isProcessing,
    bool? isAudioPlaying,
    ScreenState? finalResultStste,
    File? finalResult,
  }) {
    return FinalBossState(
      firstImage: firstImage ?? this.firstImage,
      secondImage: secondImage ?? this.secondImage,
      firstVideo: firstVideo ?? this.firstVideo,
      secondVideo: secondVideo ?? this.secondVideo,
      extratAudioStste: extratAudioStste ?? this.extratAudioStste,
      extractedAudioPath: extractedAudioPath ?? this.extractedAudioPath,
      isProcessing: isProcessing ?? this.isProcessing,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      finalResultStste: finalResultStste ?? this.finalResultStste,
      finalResult: finalResult ?? this.finalResult,
    );
  }

  @override
  List<Object?> get props {
    return [
      firstImage,
      secondImage,
      firstVideo,
      secondVideo,
      extratAudioStste,
      extractedAudioPath,
      isProcessing,
      isAudioPlaying,
      finalResultStste,
      finalResult,
    ];
  }

  @override
  bool get stringify => true;
}

enum ScreenState { loading, init, error, succes }
