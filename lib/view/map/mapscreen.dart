import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../project/widgets/project_detail_screen.dart';
import '../../bloc/project/project_cubit.dart';
import '../../models/project_model.dart';
import '../../core/constants/colors.dart';
import '../../bloc/map/map_cubit.dart';
import '../../bloc/map/map_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  // Animation controller for project list sheet
  late AnimationController _sheetAnimationController;
  late Animation<double> _sheetAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _sheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _sheetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sheetAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _sheetAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapCubit(context.read<ProjectCubit>()),
      child: BlocConsumer<MapCubit, MapState>(
        listener: (context, state) {
          // Handle state changes that require UI feedback
          if (state.errorMessage != null) {
            _showSnackBar(context, state.errorMessage!);
          }
          
          // Handle animation controllers
          if (state.isListVisible) {
            _sheetAnimationController.forward();
          } else {
            _sheetAnimationController.reverse();
          }
        },
        builder: (context, state) {
          final mapCubit = context.read<MapCubit>();
          
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.map, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Project Map',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: Stack(
              children: [
                // Map
                _buildMap(context, state),

                // Loading indicator
                if (state.isLoading) _buildLoadingIndicator(),

                // Project count chip
                Positioned(
                  top: 100,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '${state.markers.length} Projects',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected project card
                if (state.selectedProject != null) 
                  _buildProjectCard(context, state.selectedProject!),

                // Project list bottom sheet
                _buildProjectListSheet(context, state),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => mapCubit.toggleProjectList(),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              icon: Icon(state.isListVisible ? Icons.close : Icons.list),
              label: Text(state.isListVisible ? 'Close' : 'Projects'),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 70),
      ),
    );
  }

  Widget _buildMap(BuildContext context, MapState state) {
    final mapCubit = context.read<MapCubit>();
    
    return FlutterMap(
      mapController: mapCubit.mapController,
      options: MapOptions(
        initialCenter: MapCubit.defaultCenter,
        initialZoom: MapCubit.defaultZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        minZoom: 2.0,
        maxZoom: 18.0,
        onTap: (_, __) {
          if (state.selectedProject != null) {
            mapCubit.clearSelectedProject();
          }
        },
        crs: const Epsg3857(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yourdomain.app',
          tileProvider: NetworkTileProvider(),
          maxZoom: 19,
          tileSize: 256,
          keepBuffer: 5,
        ),
        PopupScope(
          child: MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 50,
              size: const Size(50, 50),
              markers: state.markers,
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.primary,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
                  ),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
              polygonOptions: const PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Loading projects...', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final mapCubit = context.read<MapCubit>();
    
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: project.thumbnail != null && project.thumbnail!.isNotEmpty
                        ? Image.memory(
                            base64Decode(project.thumbnail!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                      onPressed: () => mapCubit.clearSelectedProject(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (project.description != null && project.description!.isNotEmpty)
                    Text(
                      project.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project.locationName ?? 'Unknown location',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToProjectDetails(context, project),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProjectDetails(BuildContext context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectDetailScreen(projectId: project.id)),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(Icons.photo, size: 40, color: AppColors.primary.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildProjectListSheet(BuildContext context, MapState state) {
    final mapCubit = context.read<MapCubit>();
    
    return AnimatedBuilder(
      animation: _sheetAnimation,
      builder: (context, child) {
        // Calculate sheet height based on available screen space
        final maxHeight = MediaQuery.of(context).size.height * 0.7;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        final sheetHeight = (maxHeight - bottomPadding) * _sheetAnimation.value;
        
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: sheetHeight,
          child: Visibility(
            visible: _sheetAnimation.value > 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text('Project List', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            onPressed: () => mapCubit.toggleProjectList(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    // List
                    Expanded(
                      child: state.projects.isEmpty
                          ? _buildEmptyListMessage()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.projects.length,
                              itemBuilder: (context, index) => _buildProjectListItem(
                                context, 
                                state.projects[index]
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyListMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No projects found', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildProjectListItem(BuildContext context, Project project) {
    final mapCubit = context.read<MapCubit>();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          mapCubit.toggleProjectList();
          mapCubit.selectProject(
            project,
            project.latitude ?? MapCubit.defaultCenter.latitude,
            project.longitude ?? MapCubit.defaultCenter.longitude,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: project.thumbnail != null && project.thumbnail!.isNotEmpty
                      ? Image.memory(
                          base64Decode(project.thumbnail!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.photo, color: AppColors.primary),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: Icon(Icons.photo, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description != null && project.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            project.locationName ?? 'Unknown location',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ), 
        ),
      ),  
    );
  }
}