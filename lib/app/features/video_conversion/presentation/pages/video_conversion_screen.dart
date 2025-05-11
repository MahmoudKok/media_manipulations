import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/video_conversion_bloc.dart';

class VideoConversionScreen extends StatefulWidget {
  const VideoConversionScreen({super.key});

  @override
  State<VideoConversionScreen> createState() => _VideoConversionScreenState();
}

class _VideoConversionScreenState extends State<VideoConversionScreen> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoConversionBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Conversion")),
        body: BlocConsumer<VideoConversionBloc, VideoConversionState>(
          listener: (context, state) {
            if (state.convertedVideoInfo != null && _controller == null) {
              _controller = VideoPlayerController.file(
                  File(state.convertedVideoInfo!.path))
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
                              .read<VideoConversionBloc>()
                              .add(PickVideoEvent()),
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => context
                                .read<VideoConversionBloc>()
                                .add(ConvertVideoEvent("avi")),
                        child: const Text("Convert to AVI"),
                      ),
                      if (state.convertedVideoInfo != null)
                        Column(
                          children: [
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
                              child: Text(_controller!.value.isPlaying
                                  ? "Pause"
                                  : "Play"),
                            ),
                          ],
                        )
                    ],
                    if (state.convertedVideoInfo != null) ...[
                      const SizedBox(height: 20),
                      const Text("Converted Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.convertedVideoInfo!.path}"),
                      Text(
                          "Duration: ${state.convertedVideoInfo!.duration ?? 'Unknown'}s"),
                      Text(
                          "Resolution: ${state.convertedVideoInfo!.resolution ?? 'Unknown'}"),
                      const SizedBox(height: 20),
                      // if (_controller != null &&
                      //     _controller!.value.isInitialized
                      //     )
                      //   Column(
                      //     children: [
                      //       AspectRatio(
                      //         aspectRatio: _controller!.value.aspectRatio,
                      //         child: VideoPlayer(_controller!),
                      //       ),
                      //       ElevatedButton(
                      //         onPressed: () {
                      //           setState(() {
                      //             _controller!.value.isPlaying
                      //                 ? _controller!.pause()
                      //                 : _controller!.play();
                      //           });
                      //         },
                      //         child: Text(_controller!.value.isPlaying
                      //             ? "Pause"
                      //             : "Play"),
                      //       ),
                      //     ],
                      //   ),
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
