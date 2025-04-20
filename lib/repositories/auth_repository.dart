import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _projectsCollection = 'projects';

  // Get all projects from Firestore
  Future<List<Project>> getProjects() async {
    try {
      final snapshot = await _firestore.collection(_projectsCollection).get();
      return snapshot.docs.map((doc) => Project.fromMap(doc.data())).toList();

    } catch (e) {
      print('Error fetching projects: $e');
      throw Exception('Failed to fetch projects: $e');
    }
  }

  // Get a project by ID from Firestore
  Future<Project?> getProjectById(String projectId) async {
    try {
      final doc = await _firestore.collection(_projectsCollection).doc(projectId).get();
      if (doc.exists) {
      return Project.fromMap(doc.data()!);

      }
      return null;
    } catch (e) {
      print('Error fetching project: $e');
      throw Exception('Failed to fetch project: $e');
    }
  }

  // Add a project to Firestore
  Future<void> addProject(Map<String, dynamic> projectData) async {
    try {
      final String projectId = projectData['id'];
      await _firestore.collection(_projectsCollection).doc(projectId).set(projectData);
    } catch (e) {
      print('Error adding project: $e');
      throw Exception('Failed to add project: $e');
    }
  }

  // Update a project in Firestore
  Future<void> updateProject(String projectId, Map<String, dynamic> projectData) async {
    try {
      projectData['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection(_projectsCollection).doc(projectId).update(projectData);
    } catch (e) {
      print('Error updating project: $e');
      throw Exception('Failed to update project: $e');
    }
  }

  // Delete a project and its associated files
  Future<void> deleteProject(String projectId) async {
    try {
      // Get the project data first to access file URLs
      final project = await getProjectById(projectId);
      if (project != null) {
        // Delete images from Firebase Storage
        await _deleteStorageFolder('projects/$projectId');
        
        // Delete video files from local storage
        for (String videoPath in project.videoUrls) {
          final videoFile = File(videoPath);
          if (await videoFile.exists()) {
            await videoFile.delete();
          }
        }
        
        // Delete the project document from Firestore
        await _firestore.collection(_projectsCollection).doc(projectId).delete();
      }
    } catch (e) {
      print('Error deleting project: $e');
      throw Exception('Failed to delete project: $e');
    }
  }

  // Helper method to delete a folder in Firebase Storage
  Future<void> _deleteStorageFolder(String folderPath) async {
    try {
      final listResult = await _storage.ref().child(folderPath).listAll();
      
      // Delete all items in the folder
      for (var item in listResult.items) {
        await item.delete();
      }
      
      // Recursively delete subfolders
      for (var prefix in listResult.prefixes) {
        await _deleteStorageFolder('$folderPath/${prefix.name}');
      }
    } catch (e) {
      print('Error deleting storage folder: $e');
    }
  }
} 