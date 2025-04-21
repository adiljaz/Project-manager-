import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yelloskye/models/project_model.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference<Map<String, dynamic>> _projectsCollection;

  ProjectRepository()
      : _projectsCollection = FirebaseFirestore.instance.collection('projects');

  // Get the current user ID or throw an exception if not logged in
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // Fetch projects for the current user
  Future<List<Project>> getProjects() async {
    try {
      final userId = _getCurrentUserId();
      final querySnapshot = await _projectsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Project.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching user projects: $e");
      throw Exception('Failed to load projects');
    }
  }

  // Fetch a specific project by ID (ensuring it belongs to current user)
  Future<Project?> getProjectById(String projectId) async {
    try {
      final userId = _getCurrentUserId();
      final docSnapshot = await _projectsCollection.doc(projectId).get();
      
      if (docSnapshot.exists) {
        final projectData = docSnapshot.data()!;
        // Only return the project if it belongs to the current user
        if (projectData['userId'] == userId) {
          return Project.fromMap(projectData);
        }
      }
      return null;
    } catch (e) {
      print("Error fetching project: $e");
      throw Exception('Failed to get project');
    }
  }

  // Add a new project with current user ID
  Future<void> addProject(Project project) async {
    try {
      final userId = _getCurrentUserId();
      // Create a new map with userId added
      final projectData = project.toMap();
      projectData['userId'] = userId;
      
      await _projectsCollection.doc(project.id).set(projectData);
    } catch (e) {
      print("Error adding project: $e");
      throw Exception('Failed to add project');
    }
  }

  // Update an existing project (checking ownership)
  Future<void> updateProject(String projectId, Project project) async {
    try {
      final userId = _getCurrentUserId();
      
      // First verify this project belongs to the user
      final docSnapshot = await _projectsCollection.doc(projectId).get();
      if (!docSnapshot.exists || docSnapshot.data()!['userId'] != userId) {
        throw Exception('Project not found or access denied');
      }
      
      final updatedData = project.toMap();
      updatedData['updatedAt'] = DateTime.now().toIso8601String();
      updatedData['userId'] = userId; // Ensure userId remains correct
      
      await _projectsCollection.doc(projectId).update(updatedData);
    } catch (e) {
      print("Error updating project: $e");
      throw Exception('Failed to update project');
    }
  }
 
  // Delete a project (checking ownership)
  Future<void> deleteProject(String projectId) async {
    try {
      final userId = _getCurrentUserId();
      
      // First verify this project belongs to the user
      final docSnapshot = await _projectsCollection.doc(projectId).get();
      if (!docSnapshot.exists || docSnapshot.data()!['userId'] != userId) {
        throw Exception('Project not found or access denied');
      }
      
      await _projectsCollection.doc(projectId).delete();
    } catch (e) {
      print("Error deleting project: $e");
      throw Exception('Failed to delete project');
    }
  }
} 