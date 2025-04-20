import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../models/project_model.dart';

class MapState extends Equatable {
  final bool isLoading;
  final List<Project> projects;
  final List<Marker> markers;
  final Project? selectedProject;
  final bool isListVisible;
  final String? errorMessage;

  const MapState({
    this.isLoading = false,
    this.projects = const [],
    this.markers = const [],
    this.selectedProject,
    this.isListVisible = false,
    this.errorMessage,
  });

  MapState copyWith({
    bool? isLoading,
    List<Project>? projects,
    List<Marker>? markers,
    Project? selectedProject,
    bool? isListVisible,
    String? errorMessage,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      markers: markers ?? this.markers,
      selectedProject: selectedProject, // Pass null to clear the selection
      isListVisible: isListVisible ?? this.isListVisible,
      errorMessage: errorMessage, // Pass null to clear the error message
    );
  }

  @override
  List<Object?> get props => [
    isLoading, 
    projects, 
    markers, 
    selectedProject, 
    isListVisible, 
    errorMessage
  ];
}