import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../logger/dev_logger.dart';
import '../../models/proccess_result.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

// Assuming Dev class exists elsewhere with these methods:
// Dev.logLine(String), Dev.logLineWithTag(String tag, String message), Dev.logError(String)

// Abstract FFmpegService class with static methods
abstract class FFmpegService {
  // Static method to execute FFmpeg command and return ProcessResult
  static Future<ProcessResult<String>> execute(String command) async {
    try {
      Dev.logLine("Starting FFmpeg command execution: $command");
      Dev.logLineWithTag(
          tag: "FFmpegService", message: "Executing command: $command");

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      final isSuccess = ReturnCode.isSuccess(returnCode);
      if (returnCode != null) {
        Dev.logLine(returnCode.getValue());
      }
      if (isSuccess) {
        Dev.logLine("FFmpeg command executed successfully");
        Dev.logLineWithTag(
            tag: "FFmpegService", message: "Command completed with success");
        final logs = await session.getAllLogsAsString();
        return ProcessResult.success(
          message: "Command executed successfully",
          data: logs,
        );
      } else {
        final logs = await session.getAllLogsAsString(); // Get detailed logs
        final errorMessage =
            "FFmpeg command failed with return code: ${returnCode?.getValue()}\nLogs: $logs";
        Dev.logError(errorMessage);
        Dev.logLineWithTag(tag: "FFmpegService", message: errorMessage);
        return ProcessResult.failure(
          message: errorMessage,
        );
      }
    } catch (e) {
      final errorMessage = "Exception during FFmpeg execution: $e";
      Dev.logError(errorMessage);
      Dev.logLineWithTag(tag: "FFmpegService", message: errorMessage);
      return ProcessResult.failure(
        message: errorMessage,
      );
    }
  }

  // Static method to convert video to a new format
  static Future<ProcessResult<String>> convertVideo({
    required String videoUrl,
    required String newFormat,
  }) async {
    try {
      // Extract file name and directory from videoUrl
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-converted.$newFormat";
      final outputUrl = path.join(directory, outputFileName);

      // Construct FFmpeg command for video conversion
      // Using -c:v copy for faster conversion where possible, fallback to libx264 for compatibility
      final command = "-i \"$videoUrl\" -c:v h264  -c:a aac \"$outputUrl\"";
      // final command = "-i \"$videoUrl\" -c:v copy -c:a copy \"$outputUrl\"";

      // Log the conversion process
      Dev.logLine("Preparing to convert video: $videoUrl to $newFormat");
      Dev.logLineWithTag(
          tag: "FFmpegService", message: "Output path: $outputUrl");

      // Execute the command using the existing execute method
      final result = await execute(command);

      if (result.isSuccess) {
        // On success, return the output file path as data
        return ProcessResult.success(
          message: "Video converted successfully to $newFormat",
          data: outputUrl,
        );
      } else {
        // Forward the failure result
        return ProcessResult.failure(
          message: result.message ?? "Failed to convert video",
        );
      }
    } catch (e) {
      // Handle any exceptions (e.g., invalid file path)
      final errorMessage = "Exception during video conversion: $e";
      Dev.logError(errorMessage);
      Dev.logLineWithTag(tag: "FFmpegService", message: errorMessage);

      return ProcessResult.failure(
        message: errorMessage,
      );
    }
  }

  /// Strips all audio tracks from [inputPath], overwriting any previous output.
  static Future<String> removeAudiosFromVideo(String inputPath) async {
    final input = File(inputPath);
    if (!input.existsSync()) {
      throw ArgumentError('File not found: $inputPath');
    }

    final dir = path.dirname(inputPath);
    final base = path.basenameWithoutExtension(inputPath);
    final ext = path.extension(inputPath);
    final outputPath = path.join(dir, '$base-no-audio$ext');

    Dev.logLine('▶ Removing audio from video: $inputPath');
    Dev.logLine('   → Output will be: $outputPath');

    final args = <String>[
      '-y', // <-- force overwrite
      '-i', inputPath, // input
      '-c', 'copy', // copy all streams
      '-an', // drop audio
      outputPath, // output
    ];

    Dev.logLine('▶ FFmpeg remove‑audio command: ${args.join(' ')}');
    final session = await FFmpegKit.executeWithArguments(args);
    final rc = await session.getReturnCode();

    if (ReturnCode.isSuccess(rc)) {
      Dev.logLine('✅ Audio stripped successfully: $outputPath');
      return outputPath;
    } else {
      final logs = await session.getAllLogsAsString();
      Dev.logLine('❌ remove‑audio failed: ${logs?.split('\n').last}');
      throw Exception('removeAudio failed (rc=${rc?.getValue()}):\n$logs');
    }
  }

  static Future<ProcessResult<String>> removeAudioFromVideo({
    required String videoUrl,
  }) async {
    try {
      // Extract file name and directory
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-no-audio.mp4";
      final outputUrl = path.join(directory, outputFileName);

      // FFmpeg command to remove audio
      final command = "-i \"$videoUrl\" -c copy -an \"$outputUrl\"";

      // Logging for debug
      Dev.logLine("Removing audio from video: $videoUrl");
      Dev.logLineWithTag(
          tag: "FFmpegService", message: "Output path: $outputUrl");

      // Execute FFmpeg command
      final result = await execute(command);

      if (result.isSuccess) {
        return ProcessResult.success(
          message: "Audio removed successfully",
          data: outputUrl,
        );
      } else {
        return ProcessResult.failure(
          message: result.message ?? "Failed to remove audio",
        );
      }
    } catch (e) {
      final errorMessage = "Exception while removing audio: $e";
      Dev.logError(errorMessage);
      Dev.logLineWithTag(tag: "FFmpegService", message: errorMessage);

      return ProcessResult.failure(
        message: errorMessage,
      );
    }
  }

  static Future<ProcessResult<String>> compressVideo({
    required String videoUrl,
    String outputFormat = "mp4",
    int crf = 32,
    int audioCrf = 32,
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-compressed.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      // Optimized compression command using libx264 and CRF
      //-crf 40
      String command =
          '-y -i "$videoUrl" -c:v libx264 -crf $crf -preset fast -c:a aac -b:a ${audioCrf}k "$outputUrl"';

      Dev.logLine("Attempting compression with libx264: $command");
      ProcessResult<String> result = await execute(command);

      // If libx264 fails, try VP9 (WebM format)
      if (!result.isSuccess &&
          result.message?.contains("Unknown encoder 'libx264'") == true) {
        Dev.logLine("libx264 not available, falling back to VP9");
        command =
            "-i \"$videoUrl\" -c:v libvpx-vp9 -crf $crf -preset fast -c:a aac -b:a ${audioCrf}k \"$outputUrl\"";
        result = await execute(command);
      }

      if (result.isSuccess) {
        Dev.logLine("Compression successful: $outputUrl");
        return ProcessResult.success(
          message: "Video compressed successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Compression failed: \${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to compress video");
      }
    } catch (e) {
      final errorMessage = "Exception during video compression: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> trimVideo({
    required String videoUrl,
    required String startTime,
    required String endTime,
    String outputFormat = "mp4",
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-trimmed.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      // Trimming command
      String command =
          "-i \"$videoUrl\" -ss $startTime -to $endTime -c:v libx264 -c:a aac -preset fast \"$outputUrl\"";
      Dev.logLine("Attempting video trim: $command");

      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Trimming successful: $outputUrl");
        return ProcessResult.success(
          message: "Video trimmed successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Trimming failed: \${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to trim video");
      }
    } catch (e) {
      final errorMessage = "Exception during video trimming: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> generateThumbnail({
    required String videoUrl,
    required double time, // Seconds
    String outputFormat = "jpg",
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-thumbnail.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      String command =
          "-y -i \"$videoUrl\" -ss $time -frames:v 1 -vf scale=-2:-2 -q:v 1 \"$outputUrl\"";
      Dev.logLine("Generating thumbnail at $time seconds: $command");

      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Thumbnail generated: $outputUrl");
        return ProcessResult.success(
          message: "Thumbnail generated successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Thumbnail generation failed: ${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to generate thumbnail");
      }
    } catch (e) {
      final errorMessage = "Exception during thumbnail generation: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> extractAudio({
    required String videoUrl,
    String outputFormat = "mp3",
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-audio.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      String command =
          "-y -i \"$videoUrl\" -vn -acodec mp3 \"$outputUrl\""; // -y to overwrite
      Dev.logLine("Extracting audio: $command");

      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Audio extracted: $outputUrl");
        return ProcessResult.success(
          message: "Audio extracted successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Audio extraction failed: ${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to extract audio");
      }
    } catch (e) {
      final errorMessage = "Exception during audio extraction: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<double?> _getVideoDuration(String videoPath) async {
    final ffprobeCmd = [
      '-v',
      'quiet',
      '-print_format',
      'json',
      '-show_entries',
      'format=duration:stream=duration',
      '-i',
      videoPath,
    ].join(' ');

    final session = await FFmpegKit.execute(ffprobeCmd);
    final output = await session.getOutput();

    if (output != null && output.isNotEmpty) {
      try {
        final json = jsonDecode(output);
        // Try format duration first
        double? duration =
            double.tryParse(json['format']['duration']?.toString() ?? '');
        if (duration != null && duration > 0) {
          return duration;
        }
        // Fallback to stream duration (video stream)
        if (json['streams'] != null) {
          for (var stream in json['streams']) {
            if (stream['codec_type'] == 'video') {
              duration = double.tryParse(stream['duration']?.toString() ?? '');
              if (duration != null && duration > 0) {
                return duration;
              }
            }
          }
        }
        Dev.logError('No valid duration found for $videoPath');
      } catch (e) {
        Dev.logError('Failed to parse duration for $videoPath: $e');
      }
    }
    // Fallback: Return null to trigger error in caller
    return null;
  }

  /// Merges multiple videos end‑to‑end into one MP4, normalizing codec/frame‑rate/resolution.
  static Future<ProcessResult<String>> mergeVideos({
    required List<String> inputPaths,
    String outputFormat = 'mp4',
    int framerate = 30,
    String resolution = '1280x720',
  }) async {
    Dev.logLine('▶ mergeVideos() called with ${inputPaths.length} inputs');

    if (inputPaths.isEmpty) {
      return ProcessResult.failure(message: 'No input videos provided');
    }
    for (final p in inputPaths) {
      if (!File(p).existsSync()) {
        return ProcessResult.failure(message: 'File not found: $p');
      }
    }

    // 1) Parse resolution
    final parts = resolution.split('x');
    final resW = int.tryParse(parts[0]) ?? 1280;
    final resH = int.tryParse(parts[1]) ?? 720;
    Dev.logLine('   → Target resolution: ${resW}x$resH');

    // 2) Prepare output
    final dir = path.dirname(inputPaths.first);
    final outputPath = path.join(
      dir,
      'merged_${DateTime.now().millisecondsSinceEpoch}.$outputFormat',
    );
    Dev.logLine('   → Final output: $outputPath');

    // 3) Temp workdir
    final tmp = await getTemporaryDirectory();
    final workDir = Directory(path.join(tmp.path, 'merge_videos'));
    if (workDir.existsSync()) workDir.deleteSync(recursive: true);
    workDir.createSync();

    // 4) Transcode all to uniform specs
    final transcoded = <String>[];
    for (var i = 0; i < inputPaths.length; i++) {
      final inP = inputPaths[i];
      final outP = path.join(workDir.path, 'vid_$i.$outputFormat');
      final cmd = [
        '-y',
        '-i',
        inP,
        '-c:v',
        'libx264',
        '-preset',
        'fast',
        '-profile:v',
        'baseline',
        '-level',
        '3.0',
        '-r',
        '$framerate',
        '-vf',
        'scale=$resW:$resH:force_original_aspect_ratio=decrease,'
            'pad=$resW:$resH:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1',
        '-c:a',
        'aac',
        '-strict',
        '-2',
        outP,
      ];
      Dev.logLine('   ▶ Transcode #$i: ${cmd.join(' ')}');
      final session = await FFmpegKit.executeWithArguments(cmd);
      final rc = await session.getReturnCode();
      if (!ReturnCode.isSuccess(rc)) {
        final logs = await session.getAllLogsAsString();
        Dev.logLine('❌ Transcode failed #$i: ${logs?.split('\n').last}');
        Dev.logLine('---- Full Transcode Logs ----');
        Dev.logLine(logs);
        return ProcessResult.failure(
            message: 'Transcode failed for $inP: ${logs?.split('\n').first}');
      }
      transcoded.add(outP);
    }

    // 5) Build filelist.txt
    final listFile = File(path.join(workDir.path, 'filelist.txt'));
    final content = transcoded
        .map((p) => "file '${p.replaceAll("'", r"'\''")}'")
        .join('\n');
    listFile.writeAsStringSync(content);
    Dev.logLine('   ▶ filelist.txt written');

    // 6) Concat with demuxer
    final concatCmd = [
      '-y',
      '-f',
      'concat',
      '-safe',
      '0',
      '-i',
      listFile.path,
      '-c',
      'copy',
      outputPath,
    ];
    Dev.logLine('   ▶ Concat command: ${concatCmd.join(' ')}');
    final concatSession = await FFmpegKit.executeWithArguments(concatCmd);
    final concatRc = await concatSession.getReturnCode();

    // 7) Cleanup
    workDir.deleteSync(recursive: true);

    if (ReturnCode.isSuccess(concatRc)) {
      Dev.logLine('✅ mergeVideos succeeded: $outputPath');
      return ProcessResult.success(message: 'Merge complete', data: outputPath);
    } else {
      final logs = await concatSession.getAllLogsAsString();
      Dev.logLine('❌ mergeVideos failed: ${logs?.split('\n').last}');
      return ProcessResult.failure(
          message: 'Merge failed: ${logs?.split('\n').last}');
    }
  }

  static Future<ProcessResult<String>> addWatermark({
    required String videoUrl,
    required String watermarkText,
    String position =
        "top-left", // Options: top-left, top-right, bottom-left, bottom-right
    String fontColor = "white", // Hex or named color
    int fontSize = 24, // Font size in pixels
    String outputFormat = "mp4",
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-watermarked.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      // Copy font from assets to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fontPath = path.join(tempDir.path, "Roboto-Regular.ttf");
      if (!await File(fontPath).exists()) {
        final fontData =
            await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
        await File(fontPath).writeAsBytes(fontData.buffer.asUint8List());
      }

      String positionFilter;
      switch (position) {
        case "top-right":
          positionFilter = "x=W-180:y=20";
          break;
        case "bottom-left":
          positionFilter = "x=10:y=H-h-10";
          break;
        case "bottom-right":
          positionFilter = "x=W-w-10:y=H-h-10";
          break;
        case "top-left":
        default:
          positionFilter = "x=10:y=10";
          break;
      }

      String command =
          "-y -i \"$videoUrl\" -vf \"drawtext=fontfile='$fontPath':text='$watermarkText':fontcolor=$fontColor:fontsize=$fontSize:box=1:boxcolor=black@0.5:$positionFilter\" -c:a copy \"$outputUrl\"";
      Dev.logLine("Adding watermark: $command");

      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Watermark added: $outputUrl");
        return ProcessResult.success(
          message: "Watermark added successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Watermark addition failed: ${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to add watermark");
      }
    } catch (e) {
      final errorMessage = "Exception during watermark addition: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> addImageWatermark({
    required String videoUrl,
    required String imageUrl, // Path to the image file
    String position =
        "top-left", // Options: top-left, top-right, bottom-left, bottom-right
    String outputFormat = "mp4",
  }) async {
    try {
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-watermarked.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      String positionFilter;
      switch (position) {
        case "top-right":
          positionFilter = "x=W-w-10:y=10";
          break;
        case "bottom-left":
          positionFilter = "x=10:y=H-h-10";
          break;
        case "bottom-right":
          positionFilter = "x=W-w-10:y=H-h-10";
          break;
        case "top-left":
        default:
          positionFilter = "x=10:y=10";
          break;
      }

      String command =
          "-y -i \"$videoUrl\" -i \"$imageUrl\" -filter_complex \"[0:v][1:v]overlay=$positionFilter[outv]\" -map \"[outv]\" -map 0:a? -c:a copy \"$outputUrl\"";
      Dev.logLine("Adding image watermark: $command");

      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Image watermark added: $outputUrl");
        return ProcessResult.success(
          message: "Image watermark added successfully",
          data: outputUrl,
        );
      } else {
        Dev.logError("Image watermark addition failed: ${result.message}");
        return ProcessResult.failure(
            message: result.message ?? "Failed to add image watermark");
      }
    } catch (e) {
      final errorMessage = "Exception during image watermark addition: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> mergeVideoWithAudio({
    required String videoUrl,
    required String audioUrl,
    String outputFormat = "mp4",
  }) async {
    try {
      Dev.logLine("📁 Extracting file info...");
      final inputFileName = path.basenameWithoutExtension(videoUrl);
      final directory = path.dirname(videoUrl);
      final outputFileName = "$inputFileName-merged.$outputFormat";
      final outputUrl = path.join(directory, outputFileName);

      Dev.logLine("🎬 Preparing FFmpeg merge command...");
      final command =
          '-y -i "$videoUrl" -i "$audioUrl" -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 -shortest "$outputUrl"';
      Dev.logLine("▶ Merging video and audio: $command");

      Dev.logLine("🚀 Executing FFmpeg command...");
      ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("✅ Merge successful");
        Dev.logLine("📦 Output file: $outputUrl");
        return ProcessResult.success(
          message: "Video merged with audio successfully",
          data: outputUrl,
        );
      } else {
        Dev.logLine("❌ Merge failed");
        Dev.logError("Merging failed: ${result.message}");
        return ProcessResult.failure(
          message: result.message ?? "Failed to merge video with audio",
        );
      }
    } catch (e) {
      final errorMessage = "💥 Exception during merging: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> changeVideoResolutionByPreset({
    required String videoPath,
    required String preset, // "1080p", "720p", "480p", etc.
    String outputFormat = "mp4",
  }) async {
    try {
      final resolutionMap = {
        "1080p": [1920, 1080],
        "720p": [1280, 720],
        "480p": [854, 480],
        "360p": [640, 360],
        "240p": [426, 240],
      };

      if (!resolutionMap.containsKey(preset)) {
        return ProcessResult.failure(
          message: "Unsupported resolution preset: $preset",
        );
      }

      final width = resolutionMap[preset]![0];
      final height = resolutionMap[preset]![1];

      final inputFileName = path.basenameWithoutExtension(videoPath);
      final directory = path.dirname(videoPath);
      final outputFileName = "$inputFileName-$preset.$outputFormat";
      final outputPath = path.join(directory, outputFileName);

      final command =
          '-y -i "$videoPath" -vf "scale=$width:$height" -c:a copy "$outputPath"';
      Dev.logLine("Changing video resolution to $preset: $command");

      final ProcessResult<String> result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Resolution changed to $preset: $outputPath");
        return ProcessResult.success(
          message: "Video resolution changed successfully",
          data: outputPath,
        );
      } else {
        Dev.logError("Resolution change failed: ${result.message}");
        return ProcessResult.failure(
          message: result.message ?? "Failed to change video resolution",
        );
      }
    } catch (e) {
      final errorMessage = "Exception during resolution change: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> changeVideoQuality({
    required String videoPath,
    required String quality, // "high", "medium", "low"
    String outputFormat = "mp4",
  }) async {
    try {
      final qualityMap = {
        "high": "0", // Best quality, larger size
        "medium": "40", // Balanced
        "low": "63", // Lower quality, smaller size
      };

      if (!qualityMap.containsKey(quality)) {
        return ProcessResult.failure(
          message: "Unsupported quality level: $quality",
        );
      }

      final crfValue = qualityMap[quality]!;
      final inputFileName = path.basenameWithoutExtension(videoPath);
      final directory = path.dirname(videoPath);
      final outputFileName = "$inputFileName-$quality-quality.$outputFormat";
      final outputPath = path.join(directory, outputFileName);

      final command =
          '-y -i "$videoPath" -vcodec libvpx-vp9 -crf $crfValue -b:v 0 -preset fast -c:a copy "$outputPath"';

      Dev.logLine("Changing video quality ($quality): $command");

      final result = await execute(command);

      if (result.isSuccess) {
        Dev.logLine("Video quality changed: $outputPath");
        return ProcessResult.success(
          message: "Video quality changed to $quality",
          data: outputPath,
        );
      } else {
        Dev.logError("Video quality change failed: ${result.message}");
        return ProcessResult.failure(
          message: result.message ?? "Failed to change video quality",
        );
      }
    } catch (e) {
      final errorMessage = "Exception during quality change: $e";
      Dev.logError(errorMessage);
      return ProcessResult.failure(message: errorMessage);
    }
  }

  static Future<ProcessResult<String>> mergeImagesToVideo({
    required List<String> imagePaths,
    String outputFormat = 'mp4',
    int framerate = 24,
    int durationPerImage = 5, // Duration per image in seconds
  }) async {
    // Validate input
    if (imagePaths.isEmpty) {
      return ProcessResult.failure(message: 'Image list cannot be empty');
    }
    for (final img in imagePaths) {
      if (!File(img).existsSync()) {
        return ProcessResult.failure(message: 'Image not found: $img');
      }
    }

    // Choose codec based on output format
    String codec;
    if (outputFormat == 'mp4') {
      codec = 'libx264';
    } else if (outputFormat == 'webm') {
      codec = 'libvpx-vp9';
    } else {
      return ProcessResult.failure(
          message: 'Unsupported format: $outputFormat');
    }

    // Create temporary directory for intermediate files
    final tempDir = await Directory.systemTemp.createTemp('ffmpeg_images');
    final outputName =
        'merged_${DateTime.now().millisecondsSinceEpoch}.$outputFormat';
    final outputPath = path.join(tempDir.path, outputName);

    // Step 1: Generate individual video clips from each image
    List<String> videoPaths = [];
    for (int i = 0; i < imagePaths.length; i++) {
      final img = imagePaths[i];
      final videoPath = path.join(tempDir.path, 'clip_$i.$outputFormat');
      final cmd = [
        '-y', // Overwrite output files
        '-loop', '1', // Loop the image
        '-i', img, // Input image
        '-c:v', codec, // Video codec
        '-t', '$durationPerImage', // Duration of each clip
        '-r', '$framerate', // Frame rate
        '-pix_fmt', 'yuv420p', // Pixel format for compatibility
        videoPath, // Output file
      ].join(' ');

      final session = await FFmpegKit.execute(cmd);
      final code = await session.getReturnCode();
      if (!ReturnCode.isSuccess(code)) {
        return ProcessResult.failure(message: 'Failed to create clip for $img');
      }
      videoPaths.add(videoPath);
    }

    // Step 2: Create a list file for concatenation
    final listFilePath = path.join(tempDir.path, 'list.txt');
    String listContent = videoPaths
        .map((vp) => "file '${vp.replaceAll("'", "'\\''")}'")
        .join('\n');
    await File(listFilePath).writeAsString(listContent);

    // Step 3: Concatenate the video clips
    final concatCmd = [
      '-y', // Overwrite output
      '-f', 'concat', // Use concat demuxer
      '-safe', '0', // Allow absolute paths
      '-i', listFilePath, // List of video files
      '-c', 'copy', // Copy streams without re-encoding
      outputPath, // Final output
    ].join(' ');

    final concatSession = await FFmpegKit.execute(concatCmd);
    final concatCode = await concatSession.getReturnCode();
    if (ReturnCode.isSuccess(concatCode)) {
      return ProcessResult.success(
          data: outputPath, message: 'Video created successfully');
    }

    return ProcessResult.failure(message: 'FFmpeg concatenation failed');
  }

  static Future<String> mergeManyImagesToVideo({
    required List<String> imagePaths,
    required double duration,
  }) async {
    Dev.logLine(
        '▶ mergeManyImagesToVideo() called with ${imagePaths.length} images, duration=$duration');

    if (imagePaths.isEmpty) {
      Dev.logLine('⚠ No images provided — throwing ArgumentError');
      throw ArgumentError('No images provided.');
    }

    // 1) Build output path
    final tmpDir = await getTemporaryDirectory();
    final outputPath =
        '${tmpDir.path}/slideshow_${DateTime.now().millisecondsSinceEpoch}.mp4';
    Dev.logLine('   → Output will be: $outputPath');

    // 2) Measure all images to find canvas size
    int maxW = 0, maxH = 0;
    for (final path in imagePaths) {
      Dev.logLine('2️⃣ Reading image size: $path');
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      maxW = math.max(maxW, frame.image.width);
      maxH = math.max(maxH, frame.image.height);
    }

    // 3) Cap dimensions at 1080 on the longer side
    final isLandscape = maxW >= maxH;
    final capLongSide = 1080;
    double scaleFactor;
    if (isLandscape) {
      scaleFactor = capLongSide / maxW;
    } else {
      scaleFactor = capLongSide / maxH;
    }
    if (scaleFactor < 1.0) {
      maxW = (maxW * scaleFactor).floor();
      maxH = (maxH * scaleFactor).floor();
      Dev.logLine('   → Canvas resized to safe encoder limits: ${maxW}x$maxH');
    } else {
      Dev.logLine('   → Canvas size within limits: ${maxW}x$maxH');
    }

    // 4) Build FFmpeg arguments
    final args = <String>[];
    for (final path in imagePaths) {
      args.addAll(['-loop', '1', '-t', '$duration', '-i', path]);
    }

    // 5) Build filter_complex
    final segments = <String>[];
    for (var i = 0; i < imagePaths.length; i++) {
      segments.add('[$i:v]'
          'scale=$maxW:$maxH:force_original_aspect_ratio=decrease,'
          'pad=$maxW:$maxH:(ow-iw)/2:(oh-ih)/2:color=black,'
          'setsar=1'
          '[v$i]');
    }
    final inputsLabel = List.generate(imagePaths.length, (i) => '[v$i]').join();
    final filterComplex =
        '${segments.join(';')};$inputsLabel concat=n=${imagePaths.length}:v=1:a=0,format=yuv420p[out]';

    args.addAll([
      '-filter_complex',
      filterComplex,
      '-map',
      '[out]',
      '-r',
      '30',
      '-y',
      outputPath,
    ]);

    Dev.logLine('▶ Running FFmpeg with args:\n${args.join(' ')}');

    // 6) Execute and check
    final session = await FFmpegKit.executeWithArguments(args);
    final rc = await session.getReturnCode();
    if (ReturnCode.isSuccess(rc)) {
      Dev.logLine('✅ Video created at $outputPath');
      return outputPath;
    } else {
      Dev.logLine('❌ FFmpeg failed — fetching logs');
      final logs = await session.getAllLogs();
      final msg = logs.map((l) => l.getMessage()).join('\n');
      Dev.logLine('   → Logs:\n$msg');
      throw Exception('FFmpeg failed (rc=${rc?.getValue()}):\n$msg');
    }
  }
}
