import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/video_audio_bloc.dart';

class VideoAudioScreen extends StatefulWidget {
  const VideoAudioScreen({super.key});

  @override
  State<VideoAudioScreen> createState() => _VideoAudioScreenState();
}

class _VideoAudioScreenState extends State<VideoAudioScreen> {
  AudioPlayer? _audioPlayer;
  Duration? _duration;
  Duration? _position;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer!.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _audioPlayer!.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _audioPlayer!.onPlayerComplete.listen((_) {
      setState(() => _position = Duration.zero); // Reset to start when done
    });
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoAudioBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Audio Extraction")),
        body: BlocConsumer<VideoAudioBloc, VideoAudioState>(
          listener: (context, state) {
            if (state.audioPath != null &&
                _audioPlayer!.state == PlayerState.stopped) {
              _audioPlayer!.setSource(DeviceFileSource(state.audioPath!));
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
                              .read<VideoAudioBloc>()
                              .add(PickVideoForAudioEvent()),
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
                            : () => context
                                .read<VideoAudioBloc>()
                                .add(ExtractAudioEvent()),
                        child: const Text("Extract Audio"),
                      ),
                    ],
                    if (state.audioPath != null) ...[
                      const SizedBox(height: 20),
                      const Text("Extracted Audio Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Path: ${state.audioPath}"),
                      Text(
                          "Size: ${(File(state.audioPath!).lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB"),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_audioPlayer!.state == PlayerState.playing) {
                                await _audioPlayer!.pause();
                              } else {
                                await _audioPlayer!
                                    .play(DeviceFileSource(state.audioPath!));
                              }
                              setState(() {});
                            },
                            child: Text(
                                _audioPlayer!.state == PlayerState.playing
                                    ? "Pause"
                                    : "Play"),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await _audioPlayer!.stop();
                              setState(() => _position = Duration.zero);
                            },
                            child: const Text("Stop"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_duration != null) ...[
                        Text(
                          "${((_position?.inMilliseconds ?? 0) / 1000.0).toStringAsFixed(1)}s / ${(_duration!.inMilliseconds / 1000.0).toStringAsFixed(1)}s",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Slider(
                          value: (_position?.inMilliseconds ?? 0).toDouble(),
                          max: (_duration!.inMilliseconds).toDouble(),
                          onChanged: (value) async {
                            await _audioPlayer!
                                .seek(Duration(milliseconds: value.toInt()));
                            setState(() {});
                          },
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
