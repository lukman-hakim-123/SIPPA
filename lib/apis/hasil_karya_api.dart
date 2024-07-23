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
import 'package:sippa/models/hk.dart';

final hkAPIProvider = Provider((ref) {
  return HkAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

abstract class IHkAPI {
  FutureEither<Document> addHk(HkModel hk);
  Future<Uint8List?> getImage(String imageId);
  Future<List<Document>> getUserHk(String uid);
  Stream<RealtimeMessage> getLatestHk();
  Future<List<Document>> getKelompokHk(String kelompok);
  Future<List<Document>> getAllHk();
  FutureEither<Document> updateHk(HkModel hk);
  FutureVoid deleteHk(HkModel hk);
  FutureVoid deleteAll(String uid);
  FutureVoid deleteImage(String imageId);
}

class HkAPI implements IHkAPI {
  final Databases _db;
  final Realtime _realtime;
  final Storage _storage;
  HkAPI(
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

  @override
  FutureEither<Document> addHk(HkModel hk) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.hkCollection,
        documentId: ID.unique(),
        data: {
          ...hk.toMap(),
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
  Future<List<Document>> getUserHk(String muridId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.hkCollection,
      queries: [
        Query.equal('muridId', muridId),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokHk(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.hkCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllHk() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.hkCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestHk() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.hkCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateHk(HkModel hk) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
       collectionId: AppwriteConstants.hkCollection,
        documentId: hk.id,
        data: hk.toMap(),
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureVoid deleteImage(String imageId)async{
    try{
      await _storage.deleteFile(
        bucketId: AppwriteConstants.hkBucketId,
        fileId: imageId,
      );
    }catch (e) {
      // print(e.toString());
    }
  }
  

  @override
  FutureVoid deleteHk(HkModel hk) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.hkCollection,
        documentId: hk.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  FutureVoid deleteAll(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.hkCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );

    for (int i = 0; i < documents.documents.length; i++) {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.hkCollection,
        documentId: documents.documents[i].$id,
      );
    }
  }
}
