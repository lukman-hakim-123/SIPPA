import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/anekdot.dart';
import 'dart:io' as io;
import 'dart:typed_data';

final anekdotAPIProvider = Provider((ref) {
  return AnekdotAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

abstract class IAnekdotAPI {
  FutureEither<Document> addAnekdot(AnekdotModel anekdot);
  Future<List<Document>> getUserAnekdot(String uid);
  Stream<RealtimeMessage> getLatestAnekdot();
  Future<List<Document>> getKelompokAnekdot(String kelompok);
  Future<List<Document>> getAllAnekdot();
  FutureEither<Document> updateAnekdot(AnekdotModel anekdot);
  FutureVoid deleteAnekdot(AnekdotModel anekdot);
  FutureVoid deleteAll(String uid);
  Future<Uint8List?> getImage(String imageId);
  FutureVoid deleteImage(String imageId);
}

class AnekdotAPI implements IAnekdotAPI {
  final Databases _db;
  final Realtime _realtime;
  final Storage _storage;

  AnekdotAPI(
      {required Databases db,
      required Realtime realtime,
      required Storage storage})
      : _db = db,
        _realtime = realtime,
        _storage = storage;

  @override
  FutureEither<Document> addAnekdot(AnekdotModel anekdot) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.anekdotCollection,
        documentId: ID.unique(),
        data: anekdot.toMap(),
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

  Future<String> uploadFile(io.File file, String fileName) async {
    try {
      final result = await _storage.createFile(
        bucketId: AppwriteConstants.obsBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );
      return result.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to upload file: ${e.message}');
    }
  }

  @override
  Future<Uint8List?> getImage(String imageId) async {
    try {
      final res = await _storage.getFileView(
        bucketId: AppwriteConstants.obsBucketId,
        fileId: imageId,
      );
      return res;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  @override
  FutureVoid deleteImage(String imageId) async {
    try {
      await _storage.deleteFile(
        bucketId: AppwriteConstants.obsBucketId,
        fileId: imageId,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<List<Document>> getUserAnekdot(String muridId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.anekdotCollection,
      queries: [
        Query.equal('muridId', muridId),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokAnekdot(String kelompok) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.anekdotCollection,
      queries: [
        Query.equal('kelompok', kelompok),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllAnekdot() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.anekdotCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestAnekdot() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.anekdotCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateAnekdot(AnekdotModel anekdot) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.anekdotCollection,
        documentId: anekdot.id,
        data: {
          'pengamatan': anekdot.pengamatan,
          'tanggal': anekdot.tanggal,
          'nilai': anekdot.nilai,
          'jatiDiri': anekdot.jatiDiri,
          'literasi': anekdot.literasi,
          'umpanBalik': anekdot.umpanBalik,
          'kelompok': anekdot.kelompok,
          'imageId': anekdot.imageId,
          'muridId': anekdot.muridId,
          'tanggapan': anekdot.tanggapan,
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
  FutureVoid deleteAnekdot(AnekdotModel anekdot) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.anekdotCollection,
        documentId: anekdot.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  FutureVoid deleteAll(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.anekdotCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );

    for (int i = 0; i < documents.documents.length; i++) {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.anekdotCollection,
        documentId: documents.documents[i].$id,
      );
    }
  }
}
