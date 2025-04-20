import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/project_model.dart';
import '../../repositories/project_repository.dart';
import 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository repository;

  ProjectCubit({required this.repository}) : super(ProjectInitial());

  // Load projects with better error handling
  Future<void> loadProjects() async {
    try {
      emit(ProjectLoading());
      final projects = await repository.getProjects();
      emit(ProjectLoaded(projects: projects, filteredProjects: projects));
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // Search projects with optimization
  void searchProjects(String query) {
    if (state is ProjectLoaded) {
      final currentState = state as ProjectLoaded;

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredProjects: currentState.projects,
            searchQuery: '',
          ),
        );
        return;
      }

      final lowerQuery = query.toLowerCase();
      final filtered =
          currentState.projects
              .where(
                (project) =>
                    project.name.toLowerCase().contains(lowerQuery) ||
                    project.description.toLowerCase().contains(lowerQuery),
              )
              .toList();

      emit(
        currentState.copyWith(filteredProjects: filtered, searchQuery: query),
      );
    }
  }

  // Get project by ID with proper error handling
  Future<Project?> getProjectById(String projectId) async {
    try {
      final project = await repository.getProjectById(projectId);

      if (project != null) {
        return project;
      } else {
        emit(ProjectError("Project not found"));
        return null;
      }
    } catch (e) {
      emit(ProjectError(e.toString()));
      return null;
    }
  }

  // Add project with automatic refresh
  Future<void> addProject(Project project) async {
    try {
      await repository.addProject(project);
      await loadProjects(); // Reload projects after adding
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // Update project with automatic refresh
  Future<void> updateProject(String projectId, Project projectData) async {
    try {
      await repository.updateProject(projectId, projectData);
      await loadProjects(); // Reload projects after updating
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // Delete project with automatic refresh
  Future<void> deleteProject(String projectId) async {
    try {
      await repository.deleteProject(projectId);
      await loadProjects(); // Reload projects after deleting
    } catch (e) {
      emit(ProjectError(e.toString()));
    }
  }

  // Add video to project
  Future<void> addVideoToProject(String projectId, String videoPath) async {
    try {
      // Get the current project
      final project = await repository.getProjectById(projectId);

      if (project != null) {
        // Add the video path to the existing videos list
        final updatedVideoUrls = List<String>.from(project.videoUrls)
          ..add(videoPath);

        // Create updated project data
        final updatedProject = project.copyWith(videoUrls: updatedVideoUrls);

        // Update project in repository
        await repository.updateProject(projectId, updatedProject);

        // If we're in a loaded state, update the project in state
        if (state is ProjectLoaded) {
          final currentState = state as ProjectLoaded;
          final updatedProjects =
              currentState.projects.map((p) {
                if (p.id == projectId) {
                  return updatedProject;
                }
                return p;
              }).toList();

          emit(
            currentState.copyWith(
              projects: updatedProjects,
              filteredProjects: updatedProjects,
            ),
          );
        }
      } else {
        emit(ProjectError("Project not found"));
      }
    } catch (e) {
      emit(ProjectError("Failed to add video: ${e.toString()}"));
      throw e;
    }
  }
}
