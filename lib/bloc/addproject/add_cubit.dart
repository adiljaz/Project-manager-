import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:yelloskye/bloc/addproject/add_state.dart';
import 'package:yelloskye/bloc/project/project_cubit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:yelloskye/models/project_model.dart';

class AddProjectCubit extends Cubit<AddProjectState> {
  final ProjectCubit projectCubit;
  final ImagePicker _picker = ImagePicker();
  final uuid = const Uuid();

  AddProjectCubit({required this.projectCubit}) : super(AddProjectState());

  Future<void> requestPermissions() async {
    try {
      await [
        Permission.location,
        Permission.storage,
        Permission.photos,
        Permission.videos,
      ].request();
    } catch (e) {
      emit(state.copyWith(error: 'Error requesting permissions: $e'));
    }
  }

  Future<void> pickThumbnail() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null) {
        emit(state.copyWith(thumbnailImage: File(image.path)));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error picking thumbnail: $e'));
    }
  }

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (images.isNotEmpty) {
        final updatedImages = List<File>.from(state.projectImages)
          ..addAll(images.map((image) => File(image.path)));
        emit(state.copyWith(projectImages: updatedImages));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error picking images: $e'));
    }
  }

  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null) {
        final updatedVideos = List<File>.from(state.projectVideos)
          ..add(File(video.path));
        emit(state.copyWith(projectVideos: updatedVideos));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Error picking video: $e'));
    }
  }

  void removeImage(int index) {
    final updatedImages = List<File>.from(state.projectImages);
    updatedImages.removeAt(index);
    emit(state.copyWith(projectImages: updatedImages));
  }

  void removeVideo(int index) {
    final updatedVideos = List<File>.from(state.projectVideos);
    updatedVideos.removeAt(index);
    emit(state.copyWith(projectVideos: updatedVideos));
  }

  Future<String?> saveVideoLocally(File videoFile, String projectId) async {
    try {
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final projectDir = Directory('${appDir.path}/projects/$projectId/videos');
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${path.basename(videoFile.path)}';
      final destinationPath = '${projectDir.path}/$fileName';

      // Copy instead of move to avoid permission issues
      final File savedVideo = await videoFile.copy(destinationPath);
      
      // Make sure file was saved successfully
      if (await savedVideo.exists()) {
        return savedVideo.path;
      } else {
        throw Exception('Failed to save video file');
      }
    } catch (e) {
      emit(state.copyWith(error: 'Failed to save video: $e'));
      return null;
    }
  }

  void updateLocation(double lat, double lng) {
    emit(state.copyWith(
      latitude: lat,
      longitude: lng,
    ));
    getLocationNameFromCoordinates();
  }

  Future<void> getLocationNameFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        state.latitude,
        state.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        emit(state.copyWith(locationName: formatLocationName(place)));
      } else {
        emit(state.copyWith(locationName: 'Location found, address unavailable'));
      }
    } catch (e) {
      emit(state.copyWith(
        locationName: 'Lat: ${state.latitude.toStringAsFixed(4)}, Lng: ${state.longitude.toStringAsFixed(4)}'
      ));
    }
  }

  String formatLocationName(Placemark place) {
    List<String> addressParts = [];

    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      addressParts.add(place.thoroughfare!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  bool validateForm(GlobalKey<FormState> formKey, {required bool hasThumbnail}) {
    if (!formKey.currentState!.validate()) {
      emit(state.copyWith(error: 'Please fill all required fields'));
      return false;
    }

    if (!hasThumbnail) {
      emit(state.copyWith(error: 'Please add a thumbnail image'));
      return false;
    }

    return true;
  }

  Future<void> submitProject({
    required GlobalKey<FormState> formKey,
    required String name,
    required String description
  }) async {
    if (!validateForm(formKey, hasThumbnail: state.thumbnailImage != null)) return;

    try {
      // Reset isSuccess to false when starting a new submission
      emit(state.copyWith(
        isLoading: true,
        isSuccess: false,
        uploadStatus: 'Preparing submission...',
        uploadProgress: 0.0,
      ));

      // Generate a project ID
      final String projectId = uuid.v4();

      emit(state.copyWith(
        uploadStatus: 'Processing images...',
        uploadProgress: 0.3,
      ));

      // Convert thumbnail to base64
      String thumbnailBase64 = '';
      if (state.thumbnailImage != null) {
        List<int> thumbnailBytes = await state.thumbnailImage!.readAsBytes();
        thumbnailBase64 = base64Encode(thumbnailBytes);
      }

      // Convert project images to base64
      List<String> imageBase64List = [];
      for (File imageFile in state.projectImages) {
        List<int> imageBytes = await imageFile.readAsBytes();
        String imageBase64 = base64Encode(imageBytes);
        imageBase64List.add(imageBase64);
      }

      List<String> videoPaths = [];
      emit(state.copyWith(
        uploadStatus: 'Processing videos...',
        uploadProgress: 0.5,
      ));

      for (int i = 0; i < state.projectVideos.length; i++) {
        File videoFile = state.projectVideos[i];
        
        // Update progress for each video
        emit(state.copyWith(
          uploadStatus: 'Processing video ${i + 1} of ${state.projectVideos.length}...',
        ));
        
        final String? savedPath = await saveVideoLocally(videoFile, projectId);
        if (savedPath != null) {
          videoPaths.add(savedPath);
        }
      }

      // Create project data
      final now = DateTime.now();
      final project = Project(
        id: projectId,
        name: name.trim(),
        description: description.trim(),
        thumbnail: thumbnailBase64,
        images: imageBase64List,
        videoUrls: videoPaths,
        locationName: state.locationName,
        latitude: state.latitude,
        longitude: state.longitude,
        createdAt: now,
        updatedAt: now,
      );

      // Add project using projectCubit
      await projectCubit.addProject(project);

    

      emit(state.copyWith(
        uploadProgress: 1.0,
        uploadStatus: 'Project saved successfully!',
        isSuccess: true, // Set success state to true
      ));

      // Return success - keep isSuccess true but set isLoading to false
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false, // Ensure isSuccess is false on error
        error: 'Saving project failed: $e',
      ));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  } 
}