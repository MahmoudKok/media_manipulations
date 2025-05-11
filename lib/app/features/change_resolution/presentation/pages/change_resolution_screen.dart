import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../bloc/change_resolution_bloc.dart';

class ChangeResolutionScreen extends StatefulWidget {
  const ChangeResolutionScreen({super.key});

  @override
  State<ChangeResolutionScreen> createState() => _ChangeResolutionScreenState();
}

class _ChangeResolutionScreenState extends State<ChangeResolutionScreen> {
  VideoPlayerController? _originalController;
  VideoPlayerController? _processedController;
  String? _selectedResolution;

  @override
  void dispose() {
    _originalController?.dispose();
    _processedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChangeResolutionBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Change Video Resolution')),
        body: BlocConsumer<ChangeResolutionBloc, ChangeResolutionState>(
          listener: (context, state) async {
            // Handle original video
            if (state.originalVideoPath != null &&
                _originalController?.dataSource !=
                    'file://${state.originalVideoPath}') {
              _originalController?.dispose();
              _originalController =
                  VideoPlayerController.file(File(state.originalVideoPath!));
              await _originalController!.initialize();
              setState(() {});
            }
            // Handle processed video
            if (state.processedVideoPath != null &&
                _processedController?.dataSource !=
                    'file://${state.processedVideoPath}') {
              _processedController?.dispose();
              _processedController =
                  VideoPlayerController.file(File(state.processedVideoPath!));
              await _processedController!.initialize();
              setState(() {});
            }
            // Reset controllers if no videos
            if (state.originalVideoPath == null) {
              _originalController?.dispose();
              _originalController = null;
              _processedController?.dispose();
              _processedController = null;
              setState(() {});
            }
          },
          builder: (context, state) {
            if (state.isProcessing) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            }
            if (state.originalVideoPath == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.pickVideo(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      context
                          .read<ChangeResolutionBloc>()
                          .add(VideoSelectedEvent(pickedFile.path));
                    }
                  },
                  child: const Text('Pick Video'),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Original Video
                  if (_originalController != null &&
                      _originalController!.value.isInitialized) ...[
                    const Text('Original Video',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    AspectRatio(
                      aspectRatio: _originalController!.value.aspectRatio,
                      child: VideoPlayer(_originalController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _originalController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          _originalController!.value.isPlaying
                              ? _originalController!.pause()
                              : _originalController!.play();
                        });
                      },
                    ),
                  ] else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  // Processed Video (if available)
                  if (state.isProcessed &&
                      _processedController != null &&
                      _processedController!.value.isInitialized) ...[
                    const Text('Processed Video',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    AspectRatio(
                      aspectRatio: _processedController!.value.aspectRatio,
                      child: VideoPlayer(_processedController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _processedController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          _processedController!.value.isPlaying
                              ? _processedController!.pause()
                              : _processedController!.play();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Resolution Selection
                  if (!state.isProcessed) ...[
                    DropdownButton<String>(
                      hint: const Text('Select Resolution'),
                      value: _selectedResolution,
                      items: ['480p', '720p', '1080p'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedResolution = newValue;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: _selectedResolution != null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Processing...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              context.read<ChangeResolutionBloc>().add(
                                  ChangeVideoResolutionEvent(
                                      _selectedResolution!));
                            }
                          : null,
                      child: const Text('Change Resolution'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChangeResolutionBloc>().add(ResetEvent());
                      setState(() {
                        _selectedResolution = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
