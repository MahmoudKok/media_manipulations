import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/video_merging_bloc.dart';

class VideoMergingScreen extends StatefulWidget {
  const VideoMergingScreen({super.key});

  @override
  State<VideoMergingScreen> createState() => _VideoMergingScreenState();
}

class _VideoMergingScreenState extends State<VideoMergingScreen> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoMergingBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Merging")),
        body: BlocConsumer<VideoMergingBloc, VideoMergingState>(
          listener: (context, state) {
            if (state.mergedVideoPath != null && _controller == null) {
              _controller =
                  VideoPlayerController.file(File(state.mergedVideoPath!))
                    ..initialize().then((_) => setState(() {}));
            }
          },
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
                              .read<VideoMergingBloc>()
                              .add(PickVideosForMergingEvent()),
                      child: const Text("Pick Videos from Gallery"),
                    ),
                    const SizedBox(height: 20),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (state.errorMessage != null)
                      Text("Error: ${state.errorMessage}",
                          style: const TextStyle(color: Colors.red)),
                    if (state.selectedVideos.isNotEmpty) ...[
                      const Text("Selected Videos:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...state.selectedVideos.map((video) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Path: ${video.path}"),
                              Text("Duration: ${video.duration ?? 'Unknown'}s"),
                              Text(
                                  "Resolution: ${video.resolution ?? 'Unknown'}"),
                              Text(
                                  "Size: ${(video.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB"),
                              const SizedBox(height: 10),
                            ],
                          )),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => context
                                .read<VideoMergingBloc>()
                                .add(MergeVideosEvent()),
                        child: const Text("Merge Videos"),
                      ),
                    ],
                    if (state.mergedVideoPath != null) ...[
                      const SizedBox(height: 20),
                      const Text("Merged Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.mergedVideoPath}"),
                      Text(
                          "Size: ${(File(state.mergedVideoPath!).lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB"),
                      const SizedBox(height: 20),
                      if (_controller != null &&
                          _controller!.value.isInitialized) ...[
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Chewie(
                              controller: ChewieController(
                                  videoPlayerController: _controller!)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                          child: Text(
                              _controller!.value.isPlaying ? "Pause" : "Play"),
                        ),
                      ],
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
