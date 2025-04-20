import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yelloskye/bloc/vidoe/vidoe_cubit.dart';
import 'package:yelloskye/bloc/vidoe/vidoe_state.dart';
import 'dart:io';
import '../../../models/project_model.dart';
import '../../../core/constants/colors.dart';
  

class VideosSection extends StatelessWidget {
  final Project project;

  const VideosSection({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoCubit(project: project),
      child: BlocConsumer<VideoCubit, VideoState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<VideoCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Stack(
            children: [
              state.project.videoUrls.isEmpty
                  ? const Center(child: Text('No videos available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.project.videoUrls.length,
                      itemBuilder: (context, index) {
                        final videoPath = state.project.videoUrls[index];
                        final bool isLocalFile = state.localVideoFiles[videoPath] != null;
                        
                        return Card(
                          key: ValueKey('video_$index'),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: VideoThumbnail(
                                  videoPath: videoPath,
                                  isLocalFile: isLocalFile,
                                  onTap: () => _playVideo(context, videoPath),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Video ${index + 1}${isLocalFile ? ' (Local)' : ''}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.play_arrow),
                                          onPressed: () => _playVideo(context, videoPath),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => context.read<VideoCubit>().deleteVideo(index),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton(
                  heroTag: 'addVideoBtn',
                  onPressed: state.isUploading 
                      ? null 
                      : () => context.read<VideoCubit>().uploadVideo(),
                  backgroundColor: AppColors.primary,
                  child: state.isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.video_call),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _playVideo(BuildContext context, String videoPath) {
    final state = context.read<VideoCubit>().state;
    final localFile = state.localVideoFiles[videoPath];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (localFile != null)
              const Text('Local video file exists and can be played')
            else
              const Text('Video file not available locally'),
            const SizedBox(height: 8),
            Text(
              videoPath,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class VideoThumbnail extends StatelessWidget {
  final String videoPath;
  final bool isLocalFile;
  final VoidCallback onTap;

  const VideoThumbnail({
    super.key, 
    required this.videoPath, 
    required this.isLocalFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: isLocalFile ? Colors.blueGrey[100] : Colors.grey[200],
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: isLocalFile 
                ? const Icon(Icons.video_file, size: 64, color: Colors.blueGrey)
                : const Icon(Icons.cloud_download, size: 64, color: Colors.grey),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}