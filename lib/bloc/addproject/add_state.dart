import 'dart:io';

class AddProjectState {
  final bool isLoading;
  final bool isSuccess; // Added isSuccess flag
  final double uploadProgress;
  final String uploadStatus;
  final File? thumbnailImage;
  final List<File> projectImages;
  final List<File> projectVideos;
  final double latitude;
  final double longitude;
  final String locationName;
  final String? error;

  AddProjectState({
    this.isLoading = false,
    this.isSuccess = false, // Initialize as false
    this.uploadProgress = 0.0,
    this.uploadStatus = '',
    this.thumbnailImage,
    this.projectImages = const [],
    this.projectVideos = const [],
    this.latitude = 37.4219999,
    this.longitude = -122.0840575,
    this.locationName = 'Unknown location',
    this.error,
  });

  AddProjectState copyWith({
    bool? isLoading,
    bool? isSuccess, // Added to copyWith
    double? uploadProgress,
    String? uploadStatus,
    File? thumbnailImage,
    List<File>? projectImages,
    List<File>? projectVideos,
    double? latitude,
    double? longitude,
    String? locationName,
    String? error,
  }) {
    return AddProjectState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess, // Include in copyWith
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      projectImages: projectImages ?? this.projectImages,
      projectVideos: projectVideos ?? this.projectVideos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      error: error,
    );
  }
}