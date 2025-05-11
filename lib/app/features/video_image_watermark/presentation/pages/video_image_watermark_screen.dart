import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/video_image_watermark_bloc.dart';

class VideoImageWatermarkScreen extends StatefulWidget {
  const VideoImageWatermarkScreen({super.key});

  @override
  State<VideoImageWatermarkScreen> createState() =>
      _VideoImageWatermarkScreenState();
}

class _VideoImageWatermarkScreenState extends State<VideoImageWatermarkScreen> {
  VideoPlayerController? _controller;
  String _selectedPosition = "top-left";

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoImageWatermarkBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Image Watermark")),
        body: BlocConsumer<VideoImageWatermarkBloc, VideoImageWatermarkState>(
          listener: (context, state) {
            if (state.watermarkedVideoPath != null && _controller == null) {
              _controller =
                  VideoPlayerController.file(File(state.watermarkedVideoPath!))
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
                              .read<VideoImageWatermarkBloc>()
                              .add(PickVideoForImageWatermarkEvent()),
                      child: const Text("Pick Video from Gallery"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<VideoImageWatermarkBloc>()
                              .add(PickImageForWatermarkEvent()),
                      child: const Text("Pick Watermark Image"),
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
                    ],
                    if (state.watermarkImagePath != null) ...[
                      const SizedBox(height: 20),
                      const Text("Watermark Image:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.watermarkImagePath}"),
                      Image.file(File(state.watermarkImagePath!),
                          width: 100, height: 100, fit: BoxFit.contain),
                    ],
                    if (state.originalVideoInfo != null &&
                        state.watermarkImagePath != null) ...[
                      const SizedBox(height: 20),
                      DropdownButton<String>(
                        value: _selectedPosition,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPosition = newValue!;
                          });
                        },
                        items: <String>[
                          "top-left",
                          "top-right",
                          "bottom-left",
                          "bottom-right"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => context.read<VideoImageWatermarkBloc>().add(
                                  AddImageWatermarkEvent(
                                      state.watermarkImagePath!,
                                      _selectedPosition),
                                ),
                        child: const Text("Add Image Watermark"),
                      ),
                    ],
                    if (state.watermarkedVideoPath != null) ...[
                      const SizedBox(height: 20),
                      const Text("Watermarked Video Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.watermarkedVideoPath}"),
                      Text(
                          "Size: ${(File(state.watermarkedVideoPath!).lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB"),
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
