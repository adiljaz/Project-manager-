// lib/widgets/project_details/video_gallery.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_cubit.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_state.dart';
import 'package:yelloskye/core/constants/colors.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/common.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/permission.dart';

class VideoGallery extends StatelessWidget {
  final List<String> videos;
  
  const VideoGallery({
    Key? key,
    required this.videos
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return EmptyState(
        icon: Icons.videocam_off,
        message: 'No videos available',
        description: 'Add videos to your project to see them here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      itemBuilder:
          (context, index) => VideoCard(path: videos[index], index: index),
    );
  }
}

class VideoCard extends StatelessWidget {
  final String path;
  final int index;
  
  const VideoCard({
    Key? key,
    required this.path, 
    required this.index
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileName = path.split('/').last;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BlocProvider(
              key: ValueKey('video_player_$index'),
              create: (context) => VideoPlayerCubit(),
              child: VideoPlayer(videoPath: path),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.videocam,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadVideo(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadVideo(BuildContext context) async {
    final loadingSnackBar = SnackBar(
      content: Row(
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Text('Downloading video...'),
        ],
      ),
      duration: const Duration(
        seconds: 60,
      ), // Long duration as we'll dismiss it manually
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(loadingSnackBar);

    try {
      // Check and request permissions
      bool hasPermission = await checkAndRequestPermissions(
        skipIfExists: false,
      );
      if (!hasPermission) {
        // Close the loading snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if file exists
      File videoFile = File(path);
      if (!await videoFile.exists()) {
        throw Exception('Video file not found');
      }

      // Save to gallery using saver_gallery
      final fileName =
          'YelloSkye_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final result = await SaverGallery.saveFile(
        filePath: path,
        fileName: fileName,
        androidRelativePath: "Movies/YelloSkye",
        skipIfExists: false,
      );

      // Close the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved to Gallery'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw Exception('Failed to save video to gallery');
      }
    } catch (e) {
      // Close the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class VideoPlayer extends StatefulWidget {
  final String videoPath;
  
  const VideoPlayer({
    Key? key,
    required this.videoPath
  }) : super(key: key);

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late VideoPlayerCubit _cubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<VideoPlayerCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _isInitialized = true;
        _cubit.initializePlayer(widget.videoPath);
      }
    });
  }

  @override
  void dispose() {
    if (_isInitialized) _cubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, state) {
        if (state is VideoPlayerReady)
          return Chewie(controller: state.chewieController);
        if (state is VideoPlayerError) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, size: 40, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  const Text(
                    'Video cannot be played',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            _isInitialized
                                ? _cubit.initializePlayer(widget.videoPath)
                                : null,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }
}