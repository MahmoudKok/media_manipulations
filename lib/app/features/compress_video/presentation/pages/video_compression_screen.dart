import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/compress_video_bloc.dart';

class VideoCompressionScreen extends StatefulWidget {
  const VideoCompressionScreen({super.key});

  @override
  State<VideoCompressionScreen> createState() => _VideoCompressionScreenState();
}

class _VideoCompressionScreenState extends State<VideoCompressionScreen> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoCompressionBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Compression")),
        body: BlocConsumer<VideoCompressionBloc, VideoCompressionState>(
          listener: (context, state) {
            if (state.compressedVideoInfo != null && _controller == null) {
              _controller = VideoPlayerController.file(
                  File(state.compressedVideoInfo!.path))
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
                              .read<VideoCompressionBloc>()
                              .add(PickVideoForCompressionEvent()),
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
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<VideoCompressionBloc>().add(
                                CompressVideoEvent()), // Updated to 300 kbps
                        child: const Text("Compress Video (x kbps)"),
                      ),
                    ],
                    if (state.compressedVideoInfo != null) ...[
                      const SizedBox(height: 20),
                      const Text("Compressed Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.compressedVideoInfo!.path}"),
                      Text(
                          "Duration: ${state.compressedVideoInfo!.duration ?? 'Unknown'}s"),
                      Text(
                          "Resolution: ${state.compressedVideoInfo!.resolution ?? 'Unknown'}"),
                      Text(
                          "Size: ${(state.compressedVideoInfo!.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB"),
                      const SizedBox(height: 20),
                      if (_controller != null &&
                          _controller!.value.isInitialized) ...[
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
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
