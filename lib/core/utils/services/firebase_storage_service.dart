import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  Future<String> uploadFile({required File file}) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref =
        storage.ref().child('uploads/${DateTime.now().toString()}');
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
