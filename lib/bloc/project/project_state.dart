import 'package:equatable/equatable.dart';
import '../../models/project_model.dart';

enum ProjectStatus {
  initial,
  loading,
  loaded,
  error
}

abstract class ProjectState extends Equatable {
  const ProjectState();
  
  ProjectStatus get status;
  
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {
  @override
  ProjectStatus get status => ProjectStatus.initial;
}

class ProjectLoading extends ProjectState {
  @override
  ProjectStatus get status => ProjectStatus.loading;
}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final String searchQuery;
  
  @override
  ProjectStatus get status => ProjectStatus.loaded;
  
  const ProjectLoaded({
    required this.projects,
    required this.filteredProjects,
    this.searchQuery = '',
  });
  
  ProjectLoaded copyWith({
    List<Project>? projects,
    List<Project>? filteredProjects,
    String? searchQuery,
  }) {
    return ProjectLoaded(
      projects: projects ?? this.projects,
      filteredProjects: filteredProjects ?? this.filteredProjects,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [projects, filteredProjects, searchQuery];
}

class ProjectError extends ProjectState {
  final String message;
  
  @override
  ProjectStatus get status => ProjectStatus.error;
  
  const ProjectError(this.message);
  
  @override
  List<Object?> get props => [message];
}