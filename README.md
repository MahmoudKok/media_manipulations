# 🎥 Flutter Media Toolkit with FFmpeg

A powerful Flutter application for advanced media manipulation using [FFmpeg](https://ffmpeg.org/) via the `ffmpeg_kit_flutter` plugin. This toolkit supports a wide range of video and image processing features directly on mobile devices.

---

## ✨ Features

- 📏 **Change Resolution** – Adjust video resolution (e.g., 1080p → 720p)
- 🗜️ **Compress Video** – Reduce video file size while preserving quality
- 🧠 **Final Boss** – The most complex task (e.g., multi-stage editing or full pipeline execution)
- 🖼️ **Merge Images** – Combine multiple images into one
- 🔇 **Removing Sound** – Strip audio from video files
- 🎶 **Merge Video with Audio** – Add background music or merge external audio with video
- 🔄 **Video Conversion** – Convert between formats (MP4, AVI, MOV, etc.)
- 💧 **Video + Image Watermark** – Overlay logos, text, or images onto video
- 🎬 **Video Merging** – Join multiple video clips into one seamless output
- 🖼️ **Video Thumbnail** – Extract a frame from video as a thumbnail image
- ✂️ **Video Trimming** – Cut parts of video using start/end times
- 📝 **Video Watermark** – Add watermark text or images to video

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x or higher
- Dart 3.x
- Android Studio / Xcode
- A physical device or emulator

### Installation

```bash
flutter pub add ffmpeg_kit_flutter
````

### Permissions

Update your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

Update `Info.plist` for iOS:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need media access for editing features.</string>
<key>NSCameraUsageDescription</key>
<string>Used to record or preview videos.</string>
```

---

## 📁 Folder Structure

```
lib/
├── core/
│   └── ffmpeg_services.dart
├── app
|   ├──features/
│   ├── change_resolution/
│   ├── compress_video/
│   ├── final_boss/
│   ├── merge_images/
│   ├── merge_video_audio/
│   ├── remove_sound/
│   ├── video_conversion/
│   ├── video_merging/
│   ├── video_thumbnail/
│   ├── video_trimming/
│   ├── video_watermark/
│   └── video_image_watermark/
├── main.dart
```

---

## 🔧 Sample FFmpeg Commands

```dart
// Compress video
FFmpegServices.compressVideo("input_path");

// Merge video with audio
FFmpegServices.mergeVideos(["input_path1" , "input_path2"])

// Trim video
FFmpegServices.trimVideo("input_path" , 2 , 10);
```

---

## 🛠 Roadmap

* [x] Base command execution
* [x] Custom video resolution support
* [x] Lossy and lossless compression
* [x] Audio manipulation
* [x] Complex media merging
* [ ] Add animated preview for watermarking
* [ ] GPU acceleration toggle
* [ ] UI refinements and export logs

---

## 🤝 Contributions

Contributions are welcome! Please fork the repo, make your changes in a new branch, and submit a PR. Let’s build a robust media editor for Flutter together.

---

## 📄 License

Licensed under the MIT License. See `LICENSE` for details.

---

## 👤 Author

<table>
  <tr>
    <td>
      <img src="https://media.licdn.com/dms/image/v2/D5603AQFj_1x-AyzaDg/profile-displayphoto-shrink_800_800/B56ZY2HuscGUAo-/0/1744664720458?e=1752710400&v=beta&t=bDwxB3EQA5_WHgW1kSwS7QvHCFavSav1coToJfauk_I" 
           alt="Mahmoud's Profile" 
           width="100" 
           style="border-radius: 50%;">
    </td>
    <td style="vertical-align: middle; padding-left: 15px;">
      <strong>Mahmoud</strong> – Flutter Developer & AI Engineer<br>
      Built for real-world media processing with ❤️<br>
      <a href="https://www.linkedin.com/in/mahmoud-kokeh/">LinkedIn</a> | <a href="https://github.com/MahmoudKok">GitHub</a>
    </td>
  </tr>
</table>

