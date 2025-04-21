// lib/screens/project_detail_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_cubit.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_state.dart';
import 'package:yelloskye/core/constants/colors.dart';
import 'package:yelloskye/models/project_model.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/badge.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/common.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/imagegalary.dart.dart';
import 'package:yelloskye/view/project/projectdetails/widgets/videogalary.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        context.read<ProjectDetailsCubit>().loadProject(widget.projectId);
    });
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
        if (state is ProjectDetailsLoaded) return _buildContent(state.project);
        if (state is ProjectDetailsError) return _buildError(state.message);
        return _buildLoading();
      },
    );
  }

  Widget _buildContent(Project project) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [_buildAppBar(project)],
          body: TabBarView(
            controller: _tabController,
            children: [
              ImageGallery(images: project.images, projectName: project.name),
              VideoGallery(videos: project.videoUrls),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(Project project) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          project.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [Shadow(blurRadius: 5)],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        background: Stack(
          fit: StackFit.expand,
          children: [
            project.thumbnail != null && project.thumbnail!.isNotEmpty
                ? Hero(
                  tag: 'project_thumb_${project.id}',
                  child: Image.memory(
                    base64Decode(project.thumbnail!),
                    fit: BoxFit.cover,
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
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatBadge(
                    icon: Icons.image,
                    value: '${project.images.length}',
                  ),
                  StatBadge(
                    icon: Icons.videocam,
                    value: '${project.videoUrls.length}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(icon: Icon(Icons.image), text: 'Images'),
          Tab(icon: Icon(Icons.video_library), text: 'Videos'),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, _) => [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey[400]),
                  ),
                  bottom: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(icon: Icon(Icons.image), text: 'Images'),
                      Tab(icon: Icon(Icons.video_library), text: 'Videos'),
                    ],
                  ),
                ),
              ],
          body: TabBarView(
            controller: _tabController,
            children: [ShimmerGrid(), ShimmerList()],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
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
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  () => context.read<ProjectDetailsCubit>().loadProject(
                    widget.projectId,
                  ),
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
}
