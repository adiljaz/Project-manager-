import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../models/project_model.dart';

class VideoState extends Equatable {
  final Project project;
  final Map<String, File?> localVideoFiles;
  final bool isUploading;
  final bool isLoading;
  final String? errorMessage;

  const VideoState({
    required this.project,
    this.localVideoFiles = const {},
    this.isUploading = false,
    this.isLoading = false,
    this.errorMessage,
  });

  VideoState copyWith({
    Project? project,
    Map<String, File?>? localVideoFiles,
    bool? isUploading,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VideoState(
      project: project ?? this.project,
      localVideoFiles: localVideoFiles ?? this.localVideoFiles,
      isUploading: isUploading ?? this.isUploading,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [project, localVideoFiles, isUploading, isLoading, errorMessage];
}
