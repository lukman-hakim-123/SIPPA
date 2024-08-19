import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/observasi.dart';
import 'dart:io' as io;
import 'dart:typed_data';

final observasiAPIProvider = Provider((ref) {
  return ObservasiAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
    storage: ref.watch(appwriteStorageProvider),
  );
});

abstract class IObservasiAPI {
  FutureEither<Document> addObservasi(ObservasiModel observasi);
  Future<List<Document>> getUserObservasi(String uid);
  Stream<RealtimeMessage> getLatestObservasi();
  Future<List<Document>> getKelompokObservasi(String kelompok);
  Future<List<Document>> getAllObservasi();
  FutureEither<Document> updateObservasi(ObservasiModel observasi);
  FutureVoid deleteObservasi(ObservasiModel observasi);
  Future<Uint8List?> getImage(String imageId);
  FutureVoid deleteImage(String imageId);
}

class ObservasiAPI implements IObservasiAPI {
  final Databases _db;
  final Realtime _realtime;
  final Storage _storage;

  ObservasiAPI(
      {required Databases db,
      required Realtime realtime,
      required Storage storage})
      : _db = db,
        _realtime = realtime,
        _storage = storage;

  @override
  FutureEither<Document> addObservasi(ObservasiModel observasi) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.obsCollection,
        documentId: ID.unique(),
        data: observasi.toMap(),
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
  Future<List<Document>> getUserObservasi(String muridId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.obsCollection,
      queries: [
        Query.equal('muridId', muridId),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokObservasi(String kelompok) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.obsCollection,
      queries: [
        Query.equal('kelompok', kelompok),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllObservasi() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.obsCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestObservasi() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.obsCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateObservasi(ObservasiModel observasi) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.obsCollection,
        documentId: observasi.id,
        data: {
          'tanggal': observasi.tanggal,
          'kegiatan': observasi.kegiatan,
          'hasilObservasi': observasi.hasilObservasi,
          'rekomendasi': observasi.rekomendasi,
          'kelompok': observasi.kelompok,
          'imageId': observasi.imageId,
          'muridId': observasi.muridId,
          'tanggapan': observasi.tanggapan,
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
  FutureVoid deleteObservasi(ObservasiModel observasi) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.obsCollection,
        documentId: observasi.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }
}
