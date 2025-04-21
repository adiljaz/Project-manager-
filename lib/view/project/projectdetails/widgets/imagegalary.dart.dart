// lib/widgets/project_details/image_gallery.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:yelloskye/bloc/image/image_cubit.dart';
import 'package:yelloskye/bloc/image/image_state.dart';

import 'package:yelloskye/core/constants/colors.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/common.dart';

class ImageGallery extends StatelessWidget {
  final List<String> images;
  final String projectName;

  const ImageGallery({
    Key? key,
    required this.images,
    required this.projectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return EmptyState(icon: Icons.image, message: 'No images available');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openImageGallery(context, index),
          child: Hero(
            tag: 'project_image_$index',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(images[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openImageGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ImageGalleryCubit(
            images: images,
            projectName: projectName,
          )..changeCurrentIndex(initialIndex),
          child: const FullScreenImageGallery(),
        ),
      ),
    );
  }
}

class FullScreenImageGallery extends StatelessWidget {
  const FullScreenImageGallery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageGalleryCubit, ImageGalleryState>(
      listenWhen: (previous, current) => 
          current.downloadSuccess != null || current.downloadError != null,
      listener: (context, state) {
        if (state.downloadSuccess == true) { 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved to Gallery'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.success,
            ), 
          );
        } else if (state.downloadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save image: ${state.downloadError}'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ImageGalleryCubit>();
        
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Image ${state.currentIndex + 1}/${state.images.length}',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: state.isDownloading
                    ? Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(10),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () => cubit.downloadCurrentImage(),
                        tooltip: 'Save to gallery',
                        splashRadius: 24,
                      ),
              ),
            ],
          ),
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (context, index) => PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(
                    base64Decode(state.images[index]),
                  ),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'project_image_$index',
                  ),
                ),
                itemCount: state.images.length,
                loadingBuilder: (context, event) => Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded /
                              (event.expectedTotalBytes ?? 1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: PageController(initialPage: state.currentIndex),
                onPageChanged: (index) => cubit.changeCurrentIndex(index),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      state.images.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: state.currentIndex == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}