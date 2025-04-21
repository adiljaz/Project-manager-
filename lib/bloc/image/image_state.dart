// lib/blocs/image_gallery/image_gallery_state.dart
import 'package:equatable/equatable.dart';

class ImageGalleryState extends Equatable {
  final List<String> images;
  final int currentIndex;
  final bool isDownloading;
  final bool? downloadSuccess;
  final String? downloadError;

  const ImageGalleryState({
    required this.images,
    required this.currentIndex,
    required this.isDownloading,
    this.downloadSuccess,
    this.downloadError,
  });

  ImageGalleryState copyWith({
    List<String>? images,
    int? currentIndex,
    bool? isDownloading,
    bool? downloadSuccess,
    String? downloadError,
  }) {
    return ImageGalleryState(
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadSuccess: downloadSuccess,
      downloadError: downloadError,
    );
  }

  @override
  List<Object?> get props => [
        images,
        currentIndex,
        isDownloading,
        downloadSuccess,
        downloadError,
      ];
}