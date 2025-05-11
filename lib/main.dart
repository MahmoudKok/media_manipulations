import 'package:flutter/material.dart';
import 'package:media_manipulations/app/features/compress_video/presentation/pages/video_compression_screen.dart';
import 'package:media_manipulations/app/features/final_boss/presentation/pages/final_boss_screen.dart';
import 'package:media_manipulations/app/features/removing_sound/presentation/pages/removing_sound_screen.dart';
import 'package:media_manipulations/app/features/video_image_watermark/presentation/pages/video_image_watermark_screen.dart';
import 'package:media_manipulations/app/features/video_thumbnail/presentation/pages/video_thumbnail_screen.dart';
import 'package:media_manipulations/app/features/video_trimming/presentation/pages/video_trimming_screen.dart';
import 'package:media_manipulations/app/features/video_watermark/presentation/pages/video_watermark_screen.dart';

import 'app/features/change_resolution/presentation/pages/change_resolution_screen.dart';
import 'app/features/merge_images/presentation/pages/merge_images_screen.dart';
import 'app/features/video_audio/presentation/pages/video_audio_screen.dart';
import 'app/features/video_conversion/presentation/pages/video_conversion_screen.dart';
import 'app/features/video_merging/presentation/pages/video_merging_screen.dart'; // Adjust import path

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoConversionScreen(),
                      ));
                    },
                    child: const Text('Video Conversions'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoCompressionScreen(),
                      ));
                    },
                    child: const Text('Video Compression'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VideoTrimmingScreen(),
                      ));
                    },
                    child: const Text('Video Trimming'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const VideoThumbnailScreen()),
                    ),
                    child: const Text('Thumbnail Generation'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const VideoAudioScreen()),
                    ),
                    child: const Text('Video Audio'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const VideoMergingScreen()),
                    ),
                    child: const Text('Video Merging'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const VideoWatermarkScreen()),
                    ),
                    child: const Text('Add watermark'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              const VideoImageWatermarkScreen()),
                    ),
                    child: const Text('Image Watermarkmark'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RemovingSoundScreen()),
                    ),
                    child: const Text('Removing sound screen'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ChangeResolutionScreen()),
                    ),
                    child: const Text('Change resolution screen'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const MergeImagesScreen()),
                    ),
                    child: const Text('Merge images screen'),
                  );
                },
              ),
            ),
            Center(
              child: Builder(
                builder: (BuildContext context) {
                  // New context below Navigator
                  return ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const FinalBossScreen()),
                    ),
                    child: const Text('Final boss screen'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MainApp());
}
