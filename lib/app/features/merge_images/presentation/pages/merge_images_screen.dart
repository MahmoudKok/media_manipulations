// lib/screens/merge_images_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';

import '../bloc/merge_images_bloc.dart';

class MergeImagesScreen extends StatefulWidget {
  const MergeImagesScreen({super.key});

  @override
  State<MergeImagesScreen> createState() => _MergeImagesScreenState();
}

class _MergeImagesScreenState extends State<MergeImagesScreen> {
  // void _initializeVideo(File videoFile) {
  //   _videoController?.dispose();
  //   _chewieController?.dispose();

  //   _videoController = VideoPlayerController.file(videoFile);
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoController!,
  //     autoPlay: false,
  //     looping: false,
  //   );
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MergeImagesBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('دمج الصور إلى فيديو')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<MergeImagesBloc, MergeImagesState>(
            builder: (context, state) {
              final bloc = context.read<MergeImagesBloc>();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: bloc.countController,
                    decoration: const InputDecoration(
                      labelText: 'عدد الصور المطلوب',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final count =
                              int.tryParse(bloc.countController.text) ?? 0;
                          context
                              .read<MergeImagesBloc>()
                              .add(SetImagesCountEvent(count));
                        },
                        child: const Text('تأكيد العدد'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<MergeImagesBloc>()
                              .add(PickImagesEvent());
                        },
                        child: const Text('اختيار الصور'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.selectedImages.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        itemCount: state.selectedImages.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          return Image.file(state.selectedImages[index],
                              fit: BoxFit.cover);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (state.selectedImages.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<MergeImagesBloc>()
                            .add(MergeImagesToVideoEvent());
                      },
                      child: state.isMerging
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('دمج الصور وإنشاء الفيديو'),
                    ),
                  const SizedBox(height: 20),
                  if (state.videoFile != null)
                    if (bloc.videoController.value.isInitialized)
                      AspectRatio(
                        aspectRatio:
                            bloc.chewieController.aspectRatio ?? 16 / 9,
                        child: Chewie(controller: bloc.chewieController),
                      ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
