import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_cubit.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_state.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_cubit.dart';
import 'package:yelloskye/bloc/videoplayer/viodeplayer_state.dart';
import '../../../models/project_model.dart'; 
import '../../../core/constants/colors.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProjectDetailsCubit>().loadProject(widget.projectId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectDetailsCubit, ProjectDetailsState>(
      builder: (context, state) {
        if (state is ProjectDetailsLoading || state is ProjectDetailsInitial) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ProjectDetailsError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text('Project Details'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProjectDetailsCubit>().loadProject(widget.projectId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ProjectDetailsLoaded) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: const Text('Project Details'),
            ),
            body: const Center(
              child: Text('Unknown state'),
            ),
          );
        }

        final project = state.project;
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black45)],
                      ),
                    ),
                    background: _buildHeaderBackground(project),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(icon: Icon(Icons.image), text: 'Images'),
                      Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                ImageGallerySection(project: project),
                VideoGallerySection(project: project),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBackground(Project project) {
    return Stack(
      fit: StackFit.expand,
      children: [
        project.thumbnail != null && project.thumbnail!.isNotEmpty
            ? Image.memory(
                base64Decode(project.thumbnail!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withOpacity(0.8),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              )
            : Container(
                color: AppColors.primary,
                child: const Icon(
                  Icons.photo_album,
                  color: Colors.white30,
                  size: 80,
                ),
              ),
        // Gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              stops: const [0.6, 1.0],
            ),
          ),
        ),
        // Project stats overlay
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge(Icons.image, '${project.images.length}'),
                _buildStatBadge(
                  Icons.videocam,
                  '${project.videoUrls.length}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBadge(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ImageGallerySection extends StatelessWidget {
  final Project project;

  const ImageGallerySection({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (project.images.isEmpty) {
      return _buildEmptyState(Icons.image, 'No images available');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: project.images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, project.images[index], index),
          child: Hero(
            tag: 'image_$index',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(project.images[index]),
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

  void _showFullScreenImage(BuildContext context, String imageData, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: Hero(
              tag: 'image_$index',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  base64Decode(imageData),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey[350]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class VideoGallerySection extends StatelessWidget {
  final Project project;

  const VideoGallerySection({Key? key, required this.project})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (project.videoUrls.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: project.videoUrls.length,
      itemBuilder: (context, index) {
        final path = project.videoUrls[index];
        return _buildVideoCard(context, path, index);
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, String path, int index) {
    final fileName = path.split('/').last;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player with BLoC implementation
          AspectRatio(
            aspectRatio: 16 / 9,
            child: BlocProvider(
              create: (context) => VideoPlayerCubit(),
              child: EnhancedVideoPlayer(videoPath: path),
            ),
          ),

          // Video Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.videocam,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 80, color: Colors.grey[350]),
          const SizedBox(height: 20),
          Text(
            'No videos available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add videos to your project to see them here',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class EnhancedVideoPlayer extends StatefulWidget {
  final String videoPath;

  const EnhancedVideoPlayer({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
}

class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
  @override
  void initState() {
    super.initState();
    context.read<VideoPlayerCubit>().initializePlayer(widget.videoPath);
  }

  @override
  void dispose() {
    context.read<VideoPlayerCubit>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
      builder: (context, state) {
        if (state is VideoPlayerLoading) {
          return _buildLoadingView();
        }
        
        if (state is VideoPlayerError) {
          return _buildErrorView(context, state.errorMessage);
        }
        
        if (state is VideoPlayerReady) {
          return Chewie(controller: state.chewieController);
        }
        
        return _buildLoadingView();
      },
    );
  }
  
  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
  
  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, size: 40, color: Colors.red[300]),
                const SizedBox(height: 12),
                Text(
                  'Video cannot be played',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.read<VideoPlayerCubit>().initializePlayer(widget.videoPath),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(120, 36),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}