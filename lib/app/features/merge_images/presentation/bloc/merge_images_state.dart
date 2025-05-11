part of 'merge_images_bloc.dart';

class MergeImagesState extends Equatable {
  final int imagesCount;
  final List<File> selectedImages;
  final bool isMerging;
  final File? videoFile;

  const MergeImagesState({
    required this.imagesCount,
    required this.selectedImages,
    required this.isMerging,
    required this.videoFile,
  });

  factory MergeImagesState.initial() => const MergeImagesState(
        imagesCount: 0,
        selectedImages: [],
        isMerging: false,
        videoFile: null,
      );

  MergeImagesState copyWith({
    int? imagesCount,
    List<File>? selectedImages,
    bool? isMerging,
    File? videoFile,
  }) {
    return MergeImagesState(
      imagesCount: imagesCount ?? this.imagesCount,
      selectedImages: selectedImages ?? this.selectedImages,
      isMerging: isMerging ?? this.isMerging,
      videoFile: videoFile ?? this.videoFile,
    );
  }

  @override
  List<Object?> get props =>
      [imagesCount, selectedImages, isMerging, videoFile];
}
