part of 'change_resolution_bloc.dart';

class ChangeResolutionState extends Equatable {
  final String? originalVideoPath;
  final String? processedVideoPath;
  final bool isProcessing;
  final String? errorMessage;

  const ChangeResolutionState({
    this.originalVideoPath,
    this.processedVideoPath,
    this.isProcessing = false,
    this.errorMessage,
  });

  bool get isProcessed => processedVideoPath != null;

  @override
  List<Object?> get props =>
      [originalVideoPath, processedVideoPath, isProcessing, errorMessage];

  ChangeResolutionState copyWith({
    String? originalVideoPath,
    String? processedVideoPath,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return ChangeResolutionState(
      originalVideoPath: originalVideoPath ?? this.originalVideoPath,
      processedVideoPath: processedVideoPath ?? this.processedVideoPath,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
