import 'package:equatable/equatable.dart';
import 'package:yelloskye/models/project_model.dart';

abstract class ProjectDetailsState extends Equatable {
  const ProjectDetailsState();
  
  @override
  List<Object?> get props => [];
}

class ProjectDetailsInitial extends ProjectDetailsState {
  const ProjectDetailsInitial();
}

class ProjectDetailsLoading extends ProjectDetailsState {
  const ProjectDetailsLoading();
}

class ProjectDetailsLoaded extends ProjectDetailsState {
  final Project project;
  
  const ProjectDetailsLoaded(this.project);
  
  @override
  List<Object?> get props => [project];
}

class ProjectDetailsError extends ProjectDetailsState {
  final String message;
  
  const ProjectDetailsError(this.message);
  
  @override
  List<Object?> get props => [message];
}