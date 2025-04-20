import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  VideoPlayerCubit() : super(const VideoPlayerInitial());

  Future<void> initializePlayer(String videoPath) async {
    emit(const VideoPlayerLoading());
    
    try {
      // Check if file exists
      final File videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        emit(const VideoPlayerError('Video file not found'));
        return;
      }
      
      // Clean up previous controllers if they exist
      await _cleanUpControllers();
      
      // Initialize the video player controller with error handling
      try {
        _videoPlayerController = VideoPlayerController.file(videoFile);
        await _videoPlayerController!.initialize();
        
        // Create the chewie controller
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to play video',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        
        emit(VideoPlayerReady(_chewieController!));
      } catch (e) {
        emit(VideoPlayerError('Failed to initialize video: $e'));
      }
    } catch (e) {
      emit(VideoPlayerError('Error: ${e.toString()}'));
    }
  }

  Future<void> _cleanUpControllers() async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
  }

  @override
  Future<void> close() async {
    await _cleanUpControllers();
    return super.close();
  }
  
  void dispose() {
    _cleanUpControllers();
  }
}