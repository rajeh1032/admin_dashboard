import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseFirestore get firestore => _firestore;

  // Categories Methods
  Future<void> addCategory({
    required String name,
    required String description,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      final ref = _storage
          .ref()
          .child('categories/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('categories').add({
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String description,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      final ref = _storage
          .ref()
          .child('categories/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('categories').doc(id).update({
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').snapshots();
  }

  // Products Methods
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    final ref = _storage
        .ref()
        .child('products/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putData(imageBytes);
    final imageUrl = await ref.getDownloadURL();

    await _firestore.collection('products').add({
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String categoryId,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      final ref = _storage
          .ref()
          .child('products/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putData(imageBytes);
      imageUrl = await ref.getDownloadURL();
    }

    await _firestore.collection('products').doc(id).update({
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Stream<QuerySnapshot> getProducts() {
    return _firestore.collection('products').snapshots();
  }

  // Generic Methods
  Future<List<QueryDocumentSnapshot>> getCollection({
    required String collectionId,
    String? orderByField,
    bool descending = false,
  }) async {
    final CollectionReference reference = _firestore.collection(collectionId);
    if (orderByField != null) {
      final querySnapshot =
          await reference.orderBy(orderByField, descending: descending).get();
      return querySnapshot.docs;
    } else {
      final querySnapshot = await reference.get();
      return querySnapshot.docs;
    }
  }

  Future<List<QueryDocumentSnapshot>> getSubCollection({
    required String collectionId,
    required String documentId,
    required String subCollectionId,
    String? orderByField,
    bool descending = false,
  }) async {
    final CollectionReference reference = _firestore
        .collection(collectionId)
        .doc(documentId)
        .collection(subCollectionId);
    if (orderByField != null) {
      final querySnapshot =
          await reference.orderBy(orderByField, descending: descending).get();
      return querySnapshot.docs;
    } else {
      final querySnapshot = await reference.get();
      return querySnapshot.docs;
    }
  }

  void listenToCollection({
    required Function(List<QueryDocumentSnapshot>) onChange,
    required String collectionId,
    required String orderByField,
    bool descending = false,
  }) {
    final CollectionReference reference = _firestore.collection(collectionId);
    reference
        .orderBy(orderByField, descending: descending)
        .snapshots()
        .listen((event) => onChange(event.docs));
  }

  Future<DocumentSnapshot> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    return await _firestore.collection(collectionId).doc(documentId).get();
  }

  Future<void> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionId).doc(documentId).update(data);
  }

  Future<void> updateSubCollectionDocument({
    required String collectionId,
    required String subCollectionId,
    required String documentId,
    required String subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collectionId)
        .doc(documentId)
        .collection(subCollectionId)
        .doc(subDocumentId)
        .update(data);
  }

  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    await _firestore.collection(collectionId).doc(documentId).delete();
  }

  Future<void> deleteSubCollectionDocument({
    required String collectionId,
    required String documentId,
    required String subDocumentId,
    required String subCollectionId,
  }) async {
    await _firestore
        .collection(collectionId)
        .doc(documentId)
        .collection(subCollectionId)
        .doc(subDocumentId)
        .delete();
  }

  Future<void> addDocument({
    required String collectionId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionId).add(data);
  }

  Future<void> addDocumentUsingId({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionId).doc(documentId).set(data);
  }

  Future<void> addSubDocumentUsingId({
    required String collectionId,
    required String subCollectionId,
    required String documentId,
    required String subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(collectionId)
        .doc(documentId)
        .collection(subCollectionId)
        .doc(subDocumentId)
        .set(data);
  }

  getProductsByCategory(String s) {}
}
