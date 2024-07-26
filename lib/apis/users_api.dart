import 'dart:io' as io;
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/providers.dart';
import '../core/failure.dart';
import '../core/type_defs.dart';
import '../models/user.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(User userModel);
  Future<model.Document> getUserData(String uid);
  Future<Uint8List?> getImage(String imageId);
  FutureEither<model.Document> updateUser(User userModel);
  Future<List<model.Document>> getKelompokMurid(String kelompok);
  Future<List<model.Document>> getAllMurid();
  Stream<RealtimeMessage> getLatestMurid();
  Future<List<model.Document>> getAllGuru();
  FutureVoid deleteGuru(User user);
  FutureVoid deleteImage(String imageId);
}

class UserAPI implements IUserAPI {
  final Databases _db;
  final Realtime _realtime;
  final Storage _storage;
  UserAPI(
      {required Databases db,
      required Realtime realtime,
      required Storage storage})
      : _db = db,
        _realtime = realtime,
        _storage = storage;

  Future<String> uploadFile(io.File file, String fileName) async {
    try {
      final result = await _storage.createFile(
        bucketId: AppwriteConstants.hkBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );
      return result.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to upload file: ${e.message}');
    }
  }

  Future<Either<Failure, User>> getUserByEmail(String email) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionUserId,
        queries: [Query.equal('email', email)],
      );
      if (documents.documents.isEmpty) {
        return left(Failure('User not found', StackTrace.current));
      }
      return right(User.fromMap(documents.documents.first.data));
    } catch (e) {
      return left(Failure(e.toString(), StackTrace.current));
    }
  }

  @override
  Future<Uint8List?> getImage(String imageId) async {
    try {
      final res = await _storage.getFileView(
        bucketId: AppwriteConstants.hkBucketId,
        fileId: imageId,
      );
      return res;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  @override
  FutureEitherVoid saveUserData(User userModel) async {
    try {
      await _db.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.collectionUserId,
          documentId: userModel.id,
          data: userModel.toMap());
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<model.Document> getUserData(String uid) async {
    return await _db.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionUserId,
        documentId: uid);
  }

  @override
  FutureEither<model.Document> updateUser(User userModel) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionUserId,
        documentId: userModel.id,
        data: userModel.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureVoid deleteImage(String imageId) async {
    try {
      await _storage.deleteFile(
        bucketId: AppwriteConstants.hkBucketId,
        fileId: imageId,
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  Future<List<model.Document>> getKelompokMurid(String kelompok) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionUserId,
      queries: [
        Query.equal('levelUser', 3),
        Query.equal('kelompok', kelompok),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<model.Document>> getAllMurid() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionUserId,
      queries: [
        Query.equal('levelUser', 3),
      ],
    );
    return documents.documents;
  }

  @override 
  Stream<RealtimeMessage> getLatestMurid() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.collectionUserId}.documents',
    ]).stream;
  }

  @override
  Future<List<model.Document>> getAllGuru() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionUserId,
      queries: [
        Query.equal('levelUser', 2),
      ],
    );
    return documents.documents;
  }

  @override
  FutureVoid deleteGuru(User user) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionUserId,
        documentId: user.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }
}
