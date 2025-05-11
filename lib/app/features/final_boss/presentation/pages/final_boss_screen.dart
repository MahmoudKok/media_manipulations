import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';

import '../bloc/final_boss_bloc.dart';

class FinalBossScreen extends StatefulWidget {
  const FinalBossScreen({super.key});

  @override
  State<FinalBossScreen> createState() => _FinalBossScreenState();
}

class _FinalBossScreenState extends State<FinalBossScreen> {
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
      create: (_) => FinalBossBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Final Boss')),
        body: BlocConsumer<FinalBossBloc, FinalBossState>(
          listener: (context, state) {
            if (state.extractedAudioPath != null &&
                _audioPlayer!.state == PlayerState.stopped) {
              _audioPlayer!
                  .setSource(DeviceFileSource(state.extractedAudioPath!));
            }
          },
          builder: (context, state) {
            final bloc = context.read<FinalBossBloc>();
            return SingleChildScrollView(
              child: Column(
                children: [
                  // First Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            context.read<FinalBossBloc>().add(PickFirstImage()),
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 105, 105, 105),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: state.firstImage != null
                              ? Image.file(state.firstImage!, fit: BoxFit.cover)
                              : const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      // Second Image
                      GestureDetector(
                        onTap: () => context
                            .read<FinalBossBloc>()
                            .add(PickSecondImage()),
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 105, 105, 105),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: state.secondImage != null
                              ? Image.file(state.secondImage!,
                                  fit: BoxFit.cover)
                              : const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // First Video
                  GestureDetector(
                    onTap: () =>
                        context.read<FinalBossBloc>().add(PickFirstVideo()),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 105, 105, 105),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: state.firstVideo != null
                            ? Chewie(
                                controller: bloc.firstPlayerVideo,
                              )
                            : const Icon(
                                Icons.videocam,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.extratAudioStste == ScreenState.loading
                        ? null
                        : () => context
                            .read<FinalBossBloc>()
                            .add(ExtractAudioFromVideo()),
                    child: const Text("Extract Audio"),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  if (state.extratAudioStste == ScreenState.succes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_audioPlayer!.state == PlayerState.playing) {
                              await _audioPlayer!.pause();
                            } else {
                              await _audioPlayer!.play(
                                  DeviceFileSource(state.extractedAudioPath!));
                            }
                            setState(() {});
                          },
                          child: Text(_audioPlayer!.state == PlayerState.playing
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

                  if (state.extratAudioStste == ScreenState.succes)
                    const SizedBox(height: 20),
                  if (state.extratAudioStste == ScreenState.succes)
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

                  // Second Video
                  GestureDetector(
                    onTap: () =>
                        context.read<FinalBossBloc>().add(PickSecondVideo()),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: state.secondVideo != null
                          ? Chewie(
                              controller: bloc.seconPlayerdVideo,
                            )
                          : const Icon(Icons.videocam),
                    ),
                  ),

                  // Fire Button
                  ElevatedButton(
                    onPressed: state.isProcessing
                        ? null
                        : () => context
                            .read<FinalBossBloc>()
                            .add(FireButtonPressed()),
                    child: const Text('Fire!'),
                  ),
                  Text(
                    'FINAL RESULT',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  ),
                  if (state.finalResultStste == ScreenState.succes)
                    SizedBox(height: 30),
                  if (state.finalResultStste == ScreenState.succes)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 105, 105, 105),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: state.firstVideo != null
                            ? Chewie(
                                controller: bloc.finalPlayerdVideo,
                              )
                            : const Icon(
                                Icons.videocam,
                                color: Colors.white,
                              ),
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
