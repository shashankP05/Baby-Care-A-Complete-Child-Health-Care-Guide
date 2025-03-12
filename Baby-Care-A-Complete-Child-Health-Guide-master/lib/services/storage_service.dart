import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File file) async {
    try {
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen(
            (snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          print('Upload progress: $progress%');
        },
        onError: (error) => print('Upload error: $error'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}