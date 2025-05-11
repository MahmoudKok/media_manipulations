import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/video_thumbnail_bloc.dart';

class VideoThumbnailScreen extends StatefulWidget {
  const VideoThumbnailScreen({super.key});

  @override
  State<VideoThumbnailScreen> createState() => _VideoThumbnailScreenState();
}

class _VideoThumbnailScreenState extends State<VideoThumbnailScreen> {
  final TextEditingController _timeController =
      TextEditingController(text: "2.0");

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoThumbnailBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Thumbnail Generation")),
        body: BlocBuilder<VideoThumbnailBloc, VideoThumbnailState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<VideoThumbnailBloc>()
                              .add(PickVideoForThumbnailEvent()),
                      child: const Text("Pick Video from Gallery"),
                    ),
                    const SizedBox(height: 20),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (state.errorMessage != null)
                      Text("Error: ${state.errorMessage}",
                          style: const TextStyle(color: Colors.red)),
                    if (state.originalVideoInfo != null) ...[
                      const Text("Original Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.originalVideoInfo!.path}"),
                      Text(
                          "Duration: ${state.originalVideoInfo!.duration ?? 'Unknown'}s"),
                      Text(
                          "Resolution: ${state.originalVideoInfo!.resolution ?? 'Unknown'}"),
                      Text(
                          "Size: ${(state.originalVideoInfo!.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB"),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _timeController,
                        decoration:
                            const InputDecoration(labelText: "Time (s)"),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                final time =
                                    double.tryParse(_timeController.text) ??
                                        2.0;
                                context
                                    .read<VideoThumbnailBloc>()
                                    .add(GenerateThumbnailEvent(time));
                              },
                        child: const Text("Generate Thumbnail"),
                      ),
                    ],
                    if (state.thumbnailPath != null) ...[
                      const SizedBox(height: 20),
                      const Text("Thumbnail:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.thumbnailPath}"),
                      const SizedBox(height: 10),
                      Image.file(File(state.thumbnailPath!),
                          width: 200, height: 200, fit: BoxFit.cover),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
