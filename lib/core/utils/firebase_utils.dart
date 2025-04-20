import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class FirebaseUtils {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  static Future<String?> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      final uploadTask = ref.putFile(file);
      
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          onProgress(progress);
        });
      }
      
      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Download a file from Firebase Storage
  static Future<File?> downloadFile(String url, String filename) async {
    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      return null;
    }
  }
}