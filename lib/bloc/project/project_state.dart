import 'package:equatable/equatable.dart';
import '../../models/project_model.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();
  
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final String searchQuery;

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

  const ProjectError(this.message);

  @override
  List<Object?> get props => [message];
}