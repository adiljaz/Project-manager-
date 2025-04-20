import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yelloskye/bloc/vidoe/vidoe_state.dart';
import '../../../models/project_model.dart';

class VideoCubit extends Cubit<VideoState> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  VideoCubit({required Project project}) 
      : super(VideoState(project: project, isLoading: true)) {
    initialize();
  }

  Future<void> initialize() async {
    try {
      Map<String, File?> localVideoFiles = {};
      
      for (String videoPath in state.project.videoUrls) {
        if (videoPath.startsWith('/')) {
          // It's a local path
          File file = File(videoPath);
          if (await file.exists()) {
            localVideoFiles[videoPath] = file;
          } else {
            localVideoFiles[videoPath] = null;
          }
        } else {
          // It's a URL
          localVideoFiles[videoPath] = null;
        }
      }
      
      emit(state.copyWith(
        localVideoFiles: localVideoFiles,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to initialize videos: $e',
        isLoading: false,
      ));
    }
  }

  Future<void> uploadVideo() async {
    emit(state.copyWith(isUploading: true));
    
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) {
        emit(state.copyWith(isUploading: false));
        return;
      }

      // Save the video locally first
      final appDir = await getApplicationDocumentsDirectory();
      final projectDir = Directory('${appDir.path}/projects/${state.project.id}/videos');
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${video.name}';
      final localPath = '${projectDir.path}/$fileName';
      
      // Copy video to local storage
      final File savedVideo = await File(video.path).copy(localPath);
      
      // Also upload to Firebase Storage as backup
      final ref = _storage
          .ref()
          .child('projects/${state.project.id}/videos/$fileName');

      // Upload file to Firebase
      await ref.putFile(File(video.path));
      
      // Update project's videoUrls and localVideoFiles
      final updatedProject = state.project;
      updatedProject.videoUrls.add(localPath);
      
      final updatedLocalVideoFiles = Map<String, File?>.from(state.localVideoFiles);
      updatedLocalVideoFiles[localPath] = savedVideo;
      
      emit(state.copyWith(
        project: updatedProject,
        localVideoFiles: updatedLocalVideoFiles,
        isUploading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        errorMessage: 'Error saving video: $e',
      ));
    }
  }

  Future<void> deleteVideo(int index) async {
    try {
      final videoPath = state.project.videoUrls[index];
      
      // If it's a local file, delete it
      if (videoPath.startsWith('/')) {
        final file = File(videoPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Remove from project's videoUrls list
      final updatedProject = state.project;
      updatedProject.videoUrls.removeAt(index);
      
      final updatedLocalVideoFiles = Map<String, File?>.from(state.localVideoFiles);
      updatedLocalVideoFiles.remove(videoPath);
      
      emit(state.copyWith(
        project: updatedProject,
        localVideoFiles: updatedLocalVideoFiles,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error deleting video: $e',
      ));
    }
  }

  // No state changes for playVideo, it's handled in the UI
  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }
}