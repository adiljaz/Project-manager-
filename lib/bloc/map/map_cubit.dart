import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yelloskye/bloc/project/project_state.dart';
import '../../models/project_model.dart';
import '../../bloc/project/project_cubit.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final ProjectCubit _projectCubit;
  final MapController mapController = MapController();

  // Map settings
  static const LatLng defaultCenter = LatLng(37.4219999, -122.0840575);
  static const double defaultZoom = 5.0;

  MapCubit(this._projectCubit) : super(const MapState()) {
    _init();
  }

  void _init() {
    loadProjects();
    Future.delayed(const Duration(seconds: 1), requestLocationPermission);
  }

  @override
  Future<void> close() {
    mapController.dispose();
    return super.close();
  }

  Future<void> loadProjects() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _projectCubit.loadProjects();
      final projects = (_projectCubit.state as ProjectLoaded).projects;

      final markers = _createMarkersFromProjects(projects);

      emit(
        state.copyWith(isLoading: false, projects: projects, markers: markers),
      );

      if (markers.isNotEmpty) {
        fitMapToMarkers();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load projects. Pull down to refresh.',
        ),
      );
    }
  }

  List<Marker> _createMarkersFromProjects(List<Project> projects) {
    if (projects.isEmpty) return [];

    final List<Marker> markers = [];

    for (final project in projects) {
      final lat =
          project.latitude;
      final lng =
          project.longitude;

      final marker = Marker(
        width: 50.0,
        height: 50.0,
        point: LatLng(lat, lng),
        child: GestureDetector(
          onTap: () => selectProject(project, lat, lng),
          child: _buildMarkerWidget(project),
        ),
      );

      markers.add(marker);
    }

    return markers;
  }

  Widget _buildMarkerWidget(Project project) {

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Container(
          width: 40,
          height: 40,
          color: project.thumbnail != null ? null : Colors.blue[100],
          child:
              project.thumbnail != null && project.thumbnail!.isNotEmpty
                  ? Image.memory(
                    base64Decode(
                      project.thumbnail!,
                    ), // Decode the base64 string to bytes
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 30,
                        ),
                  )
                  : Icon(Icons.location_on, color: Colors.blue, size: 30),
        ),
      ),
    );
  }

  void selectProject(Project project, double lat, double lng) {
    mapController.move(LatLng(lat, lng), 12.0);

    // Hide project list if visible
    if (state.isListVisible) {
      toggleProjectList();
    }

    emit(state.copyWith(selectedProject: project));
  }

  void clearSelectedProject() {
    emit(state.copyWith(selectedProject: null));
  }

  void fitMapToMarkers() {
    if (state.markers.isEmpty) return;

    final points = state.markers.map((marker) => marker.point).toList();

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    final bounds = LatLngBounds(
      LatLng(minLat - 0.5, minLng - 0.5),
      LatLng(maxLat + 0.5, maxLng + 0.5), 
    );

    mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50.0)),
    );
  }

  void toggleProjectList() {
    emit(state.copyWith(isListVisible: !state.isListVisible));
  }

  Future<void> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(errorMessage: 'Location services are disabled'));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(errorMessage: 'Location permissions are denied'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        state.copyWith(
          errorMessage: 'Location permissions are permanently denied',
        ),
      );
    }
  }
}
