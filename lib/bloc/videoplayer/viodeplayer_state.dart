import 'package:chewie/chewie.dart';
import 'package:equatable/equatable.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();
  
  @override
  List<Object?> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial();
}

class VideoPlayerLoading extends VideoPlayerState {
  const VideoPlayerLoading();
}

class VideoPlayerReady extends VideoPlayerState {
  final ChewieController chewieController;
  
  const VideoPlayerReady(this.chewieController);
  
  @override
  List<Object?> get props => [chewieController];
}

class VideoPlayerError extends VideoPlayerState {
  final String errorMessage;
  
  const VideoPlayerError(this.errorMessage);
  
  @override
  List<Object?> get props => [errorMessage];
}