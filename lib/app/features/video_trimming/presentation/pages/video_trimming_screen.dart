import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/video_trimming_bloc.dart';

class VideoTrimmingScreen extends StatefulWidget {
  const VideoTrimmingScreen({super.key});

  @override
  State<VideoTrimmingScreen> createState() => _VideoTrimmingScreenState();
}

class _VideoTrimmingScreenState extends State<VideoTrimmingScreen> {
  ChewieController? _controller;
  final TextEditingController _startController =
      TextEditingController(text: "2.0");
  final TextEditingController _endController =
      TextEditingController(text: "5.0");

  @override
  void dispose() {
    _controller?.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoTrimmingBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Trimming")),
        body: BlocConsumer<VideoTrimmingBloc, VideoTrimmingState>(
          listener: (context, state) {
            if (state.trimmedVideoInfo != null && _controller == null) {
              _controller = ChewieController(
                  looping: true,
                  showControls: true,
                  showOptions: true,
                  videoPlayerController: VideoPlayerController.file(
                      File(state.trimmedVideoInfo!.path))
                    ..initialize().then((_) => setState(() {})));
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
                              .read<VideoTrimmingBloc>()
                              .add(PickVideoForTrimmingEvent()),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _startController,
                              decoration: const InputDecoration(
                                  labelText: "Start Time (s)"),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _endController,
                              decoration: const InputDecoration(
                                  labelText: "End Time (s)"),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                final start =
                                    double.tryParse(_startController.text) ??
                                        2.0;
                                final end =
                                    double.tryParse(_endController.text) ?? 5.0;
                                if (end > start) {
                                  context
                                      .read<VideoTrimmingBloc>()
                                      .add(TrimVideoEvent(start, end));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "End time must be greater than start time")),
                                  );
                                }
                              },
                        child: const Text("Trim Video"),
                      ),
                    ],
                    if (state.trimmedVideoInfo != null) ...[
                      const SizedBox(height: 20),
                      const Text("Trimmed Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.trimmedVideoInfo!.path}"),
                      Text(
                          "Duration: ${state.trimmedVideoInfo!.duration ?? 'Unknown'}s"),
                      Text(
                          "Resolution: ${state.trimmedVideoInfo!.resolution ?? 'Unknown'}"),
                      Text(
                          "Size: ${(state.trimmedVideoInfo!.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB"),
                      const SizedBox(height: 20),
                      if (_controller != null &&
                          _controller!
                              .videoPlayerController.value.isInitialized) ...[
                        AspectRatio(
                          aspectRatio: _controller!
                              .videoPlayerController.value.aspectRatio,
                          child: Chewie(
                            controller: _controller!,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _controller!.videoPlayerController.value.isPlaying
                                  ? _controller!.pause()
                                  : _controller!.play();
                            });
                          },
                          child: Text(
                              _controller!.videoPlayerController.value.isPlaying
                                  ? "Pause"
                                  : "Play"),
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
