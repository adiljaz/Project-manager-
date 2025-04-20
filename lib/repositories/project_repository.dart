import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yelloskye/models/project_model.dart';

class ProjectRepository {
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _projectsCollection;

  ProjectRepository()
    : _projectsCollection = FirebaseFirestore.instance.collection('projects');

  // Fetch all projects
  Future<List<Project>> getProjects() async {
    try {
      final querySnapshot = await _projectsCollection.get();
      return querySnapshot.docs
          .map((doc) => Project.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching projects: $e");
      throw Exception('Failed to load projects');
    }
  }

  // Fetch a specific project by ID
  Future<Project?> getProjectById(String projectId) async {
    try {
      final docSnapshot = await _projectsCollection.doc(projectId).get();
      if (docSnapshot.exists) {
        return Project.fromMap(docSnapshot.data()!);

      }
      return null;
    } catch (e) {
      print("Error fetching project: $e");
      throw Exception('Failed to get project');
    }
  }

  // Add a new project
  Future<void> addProject(Project project) async {
    try {
      await _projectsCollection.doc(project.id).set(project.toMap());
    } catch (e) {
      print("Error adding project: $e");
      throw Exception('Failed to add project');
    }
  }

  // Update an existing project
  Future<void> updateProject(String projectId, Project project) async {
    try {
      final updatedData =
          project.toMap()..['updatedAt'] = DateTime.now().toIso8601String();
      await _projectsCollection.doc(projectId).update(updatedData);
    } catch (e) {
      print("Error updating project: $e");
      throw Exception('Failed to update project');
    }
  }

  // Delete a project by ID
  Future<void> deleteProject(String projectId) async {
    try {
      await _projectsCollection.doc(projectId).delete();
    } catch (e) {
      print("Error deleting project: $e");
      throw Exception('Failed to delete project');
    }
  }
}
