import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yelloskye/bloc/projectdetails/projectdetails_state.dart';
import 'package:yelloskye/models/project_model.dart';

class ProjectDetailsCubit extends Cubit<ProjectDetailsState> {
  final FirebaseFirestore _firestore;
  
  ProjectDetailsCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const ProjectDetailsInitial());
  
  Future<void> loadProject(String projectId) async {
    try {
      emit(const ProjectDetailsLoading());
      final project = await getProjectById(projectId);
      emit(ProjectDetailsLoaded(project));
    } catch (e) {
      emit(ProjectDetailsError('Error loading project: $e'));
    }
  }
  
  Future<Project> getProjectById(String projectId) async {
    try {
      final docSnapshot = await _firestore.collection('projects').doc(projectId).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Project not found');
      }
      
      final data = docSnapshot.data();
      if (data == null) {
        throw Exception('Project data is null');
      }
      
      return Project.fromMap({
        'id': docSnapshot.id,
        ...data,
      });
    } catch (e) {
      throw Exception('Failed to fetch project: $e');
    }
  }
}