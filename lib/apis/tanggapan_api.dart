import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/to.dart';

final tanggapanAPIProvider = Provider((ref) {
  return TanggapanAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class ITanggapanAPI {
  FutureEither<Document> addTanggapan(TanggapanModel tanggapan);
  Future<List<Document>> getUserTanggapan(String uid);
  Stream<RealtimeMessage> getLatestTanggapan();
  Future<List<Document>> getKelompokTanggapan(String kelompok);
  Future<List<Document>> getAllTanggapan();
  FutureEither<Document> updateTanggapan(TanggapanModel tanggapan);
  FutureVoid deleteTanggapan(TanggapanModel tanggapan);
}

class TanggapanAPI implements ITanggapanAPI {
  final Databases _db;
  final Realtime _realtime;
  TanggapanAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> addTanggapan(TanggapanModel tanggapan) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.toCollection,
        documentId: ID.unique(),
        data: tanggapan.toMap(),
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
  Future<List<Document>> getUserTanggapan(String muridId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.toCollection,
      queries: [
        Query.equal('muridId', muridId),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokTanggapan(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.toCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllTanggapan() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.toCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestTanggapan() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.toCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateTanggapan(TanggapanModel tanggapan) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.toCollection,
        documentId: tanggapan.id,
        data: {
          'tanggapan': tanggapan.tanggapan,
          'tanggal': tanggapan.tanggal,
          'balasan': tanggapan.balasan,
          'muridId': tanggapan.muridId,
          'uid': tanggapan.uid,
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
  FutureVoid deleteTanggapan(TanggapanModel tanggapan) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.toCollection,
        documentId: tanggapan.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }
}
