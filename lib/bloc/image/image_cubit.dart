// lib/blocs/image_gallery/image_gallery_cubit.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:yelloskye/bloc/image/image_state.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/permission.dart';

class ImageGalleryCubit extends Cubit<ImageGalleryState> {
  final List<String> images;
  final String projectName;

  ImageGalleryCubit({
    required this.images,
    required this.projectName,
  }) : super(ImageGalleryState(
          images: images,
          currentIndex: 0, 
          isDownloading: false,
        ));

  void changeCurrentIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  Future<void> downloadCurrentImage() async {
    if (state.isDownloading) return;

    emit(state.copyWith(isDownloading: true));

    try {
      // Request permission first
      bool hasPermission = await checkAndRequestPermissions(
        skipIfExists: false,
      );
      
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get image data
      final imageData = base64Decode(images[state.currentIndex]);
      final fileName = 'YelloSkye_${projectName}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save to gallery using saver_gallery
      final result = await SaverGallery.saveImage(
        Uint8List.fromList(imageData),
        quality: 100,
        fileName: fileName,
        androidRelativePath: "Pictures/YelloSkye",
        skipIfExists: false,
      );

      if (result == null) {
        throw Exception('Failed to save image to gallery');
      }
      
      emit(state.copyWith(
        downloadSuccess: true,
        downloadError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        downloadSuccess: false,
        downloadError: e.toString(),
      ));
    } finally {
      emit(state.copyWith(
        isDownloading: false,
        // Reset these flags after they've been consumed
        downloadSuccess: null,
        downloadError: null,
      ));
    }
  }
}