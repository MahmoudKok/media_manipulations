import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../bloc/removing_sound_bloc.dart';

class RemovingSoundScreen extends StatefulWidget {
  const RemovingSoundScreen({super.key});

  @override
  State<RemovingSoundScreen> createState() => _RemovingSoundScreenState();
}

class _RemovingSoundScreenState extends State<RemovingSoundScreen> {
  VideoPlayerController? _originalController;
  VideoPlayerController? _processedController;
  VideoPlayerController? _mergedController;

  @override
  void dispose() {
    _originalController?.dispose();
    _processedController?.dispose();
    _mergedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RemovingSoundBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Remove and Merge Video Sound')),
        body: BlocConsumer<RemovingSoundBloc, RemovingSoundState>(
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
            // Handle merged video
            if (state.mergedVideoPath != null &&
                _mergedController?.dataSource !=
                    'file://${state.mergedVideoPath}') {
              _mergedController?.dispose();
              _mergedController =
                  VideoPlayerController.file(File(state.mergedVideoPath!));
              await _mergedController!.initialize();
              setState(() {});
            }
            // Reset controllers if no videos
            if (state.originalVideoPath == null) {
              _originalController?.dispose();
              _originalController = null;
              _processedController?.dispose();
              _processedController = null;
              _mergedController?.dispose();
              _mergedController = null;
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
                          .read<RemovingSoundBloc>()
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
                    const Text('Processed Video (No Sound)',
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
                  // Merged Video (if available)
                  if (state.isMerged &&
                      _mergedController != null &&
                      _mergedController!.value.isInitialized) ...[
                    const Text('Merged Video',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    AspectRatio(
                      aspectRatio: _mergedController!.value.aspectRatio,
                      child: VideoPlayer(_mergedController!),
                    ),
                    IconButton(
                      icon: Icon(
                        _mergedController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        setState(() {
                          _mergedController!.value.isPlaying
                              ? _mergedController!.pause()
                              : _mergedController!.play();
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Buttons
                  if (!state.isProcessed)
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<RemovingSoundBloc>()
                            .add(RemoveSoundEvent());
                      },
                      child: const Text('Remove Sound'),
                    )
                  else if (!state.isMerged) ...[
                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final pickedFile =
                            await picker.pickVideo(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          context
                              .read<RemovingSoundBloc>()
                              .add(AnotherVideoSelectedEvent(pickedFile.path));
                          context
                              .read<RemovingSoundBloc>()
                              .add(MergeAudioEvent());
                        }
                      },
                      child: const Text('Pick Another Video'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: () {
                      context.read<RemovingSoundBloc>().add(ResetEvent());
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
