import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yelloskye/core/constants/colors.dart';
import 'package:yelloskye/models/project_model.dart';
import 'package:yelloskye/view/project/widgets/project_detail_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project image with overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  _buildProjectImage(),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildMediaIndicatorBadge(),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildGradientOverlay(),
                  ),
                ],
              ),
            ),

            // Project info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  _buildProjectMetadata(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
    );
  }

  Widget _buildProjectImage() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: project.thumbnail != null && project.thumbnail!.isNotEmpty
          ? _buildImageFromBase64(project.thumbnail!)
          : project.images.isNotEmpty
              ? _buildImageFromBase64(project.images.first)
              : _buildPlaceholderImage(),
    );
  }

  Widget _buildImageFromBase64(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMediaIndicatorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.photo_library, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('${project.images.length}', style: _badgeTextStyle()),
          const SizedBox(width: 6),
          const Icon(Icons.video_library, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text('${project.videoUrls.length}', style: _badgeTextStyle()),
        ],
      ),
    );
  }

  TextStyle _badgeTextStyle() => const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      );

  Widget _buildProjectMetadata() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildInfoChip(Icons.image, '${project.images.length} Images'),
        const SizedBox(width: 12),
        _buildInfoChip(Icons.videocam, '${project.videoUrls.length} Videos'),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],  
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(projectId: project.id),
      ),
    );
  }
}
 