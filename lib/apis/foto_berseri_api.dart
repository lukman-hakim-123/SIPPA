import 'dart:io' as io;
import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/fb.dart';

final fbAPIProvider = Provider((ref) {
  return FbAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

abstract class IFbAPI {
  FutureEither<Document> addFb(FbModel fb);
  Future<Uint8List?> getImage(String imageId);
  Future<List<Document>> getUserFb(String uid, String sekolah);
  Stream<RealtimeMessage> getLatestFb();
  Future<List<Document>> getKelompokFb(String kelompok, String sekolah);
  Future<List<Document>> getAllFb(String sekolah);
  FutureEither<Document> updateFb(FbModel fb);
  FutureVoid deleteFb(FbModel fb);
  FutureVoid deleteImage(String imageId);
}

class FbAPI implements IFbAPI {
  final Databases _db;
  final Realtime _realtime;
  final Storage _storage;
  FbAPI({
    required Databases db,
    required Realtime realtime,
    required Storage storage,
  })  : _db = db,
        _realtime = realtime,
        _storage = storage;

  Future<String> uploadFile(io.File file, String fileName) async {
    try {
      final result = await _storage.createFile(
        bucketId: AppwriteConstants.fbBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );
      return result.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to upload file: ${e.message}');
    }
  }

  @override
  FutureEither<Document> addFb(FbModel fb) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fbCollection,
        documentId: ID.unique(),
        data: {
          ...fb.toMap(),
          'sekolah': fb.sekolah,
        },
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
  Future<Uint8List?> getImage(String imageId) async {
    try {
      final res = await _storage.getFileView(
        bucketId: AppwriteConstants.fbBucketId,
        fileId: imageId,
      );
      return res;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  @override
  Future<List<Document>> getUserFb(String muridId, String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.fbCollection,
      queries: [
        Query.equal('muridId', muridId),
        Query.equal('sekolah', sekolah),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokFb(String uid, String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.fbCollection,
      queries: [
        Query.equal('uid', uid),
        Query.equal('sekolah', sekolah),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllFb(String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.fbCollection,
      queries: [
        Query.equal('sekolah', sekolah),
      ],
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestFb() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.fbCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateFb(FbModel fb) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fbCollection,
        documentId: fb.id,
        data: {
          ...fb.toMap(),
          'sekolah': fb.sekolah,
        },
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureVoid deleteImage(String imageId) async {
    try {
      await _storage.deleteFile(
        bucketId: AppwriteConstants.fbBucketId,
        fileId: imageId,
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  FutureVoid deleteFb(FbModel fb) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.fbCollection,
        documentId: fb.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }
}
