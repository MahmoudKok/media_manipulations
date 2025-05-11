import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:video_player/video_player.dart';

import '../bloc/video_watermark_bloc.dart';

class VideoWatermarkScreen extends StatefulWidget {
  const VideoWatermarkScreen({super.key});

  @override
  State<VideoWatermarkScreen> createState() => _VideoWatermarkScreenState();
}

class _VideoWatermarkScreenState extends State<VideoWatermarkScreen> {
  VideoPlayerController? _controller;
  final TextEditingController _textController =
      TextEditingController(text: "My Watermark");
  final TextEditingController _sizeController =
      TextEditingController(text: "24");
  String _selectedPosition = "top-left";
  Color _selectedColor = Colors.white;

  @override
  void dispose() {
    _controller?.dispose();
    _textController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pick a Color"),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (Color color) {
              setState(() => _selectedColor = color);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoWatermarkBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Video Watermark")),
        body: BlocConsumer<VideoWatermarkBloc, VideoWatermarkState>(
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
                              .read<VideoWatermarkBloc>()
                              .add(PickVideoForWatermarkEvent()),
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
                        controller: _textController,
                        decoration:
                            const InputDecoration(labelText: "Watermark Text"),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _sizeController,
                        decoration:
                            const InputDecoration(labelText: "Font Size"),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text("Font Color: "),
                          GestureDetector(
                            onTap: () => _showColorPicker(context),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            : () {
                                final fontSize =
                                    int.tryParse(_sizeController.text) ?? 24;
                                final fontColor =
                                    '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                                context.read<VideoWatermarkBloc>().add(
                                      AddWatermarkEvent(
                                        _textController.text,
                                        _selectedPosition,
                                        fontColor,
                                        fontSize,
                                      ),
                                    );
                              },
                        child: const Text("Add Watermark"),
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
