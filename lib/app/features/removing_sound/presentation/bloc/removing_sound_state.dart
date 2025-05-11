part of 'removing_sound_bloc.dart';

class RemovingSoundState extends Equatable {
  final String? originalVideoPath;
  final String? processedVideoPath;
  final String? anotherVideoPath;
  final String? mergedVideoPath;
  final bool isProcessing;
  final String? errorMessage;

  const RemovingSoundState({
    this.originalVideoPath,
    this.processedVideoPath,
    this.anotherVideoPath,
    this.mergedVideoPath,
    this.isProcessing = false,
    this.errorMessage,
  });

  bool get isProcessed => processedVideoPath != null;
  bool get isMerged => mergedVideoPath != null;

  @override
  List<Object?> get props => [
        originalVideoPath,
        processedVideoPath,
        anotherVideoPath,
        mergedVideoPath,
        isProcessing,
        errorMessage
      ];

  RemovingSoundState copyWith({
    String? originalVideoPath,
    String? processedVideoPath,
    String? anotherVideoPath,
    String? mergedVideoPath,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return RemovingSoundState(
      originalVideoPath: originalVideoPath ?? this.originalVideoPath,
      processedVideoPath: processedVideoPath ?? this.processedVideoPath,
      anotherVideoPath: anotherVideoPath ?? this.anotherVideoPath,
      mergedVideoPath: mergedVideoPath ?? this.mergedVideoPath,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
