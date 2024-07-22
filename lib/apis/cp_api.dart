import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/cp.dart';

final cpAPIProvider = Provider((ref) {
  return CpAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class ICpAPI {
  FutureEither<Document> addCp(CpModel cp);
  Future<List<Document>> getUserCp(String uid);
  Stream<RealtimeMessage> getLatestCp();
  Future<List<Document>> getKelompokCp(String kelompok);
  Future<List<Document>> getAllCp();
  FutureEither<Document> updateCp(CpModel cp);
  FutureVoid deleteCp(CpModel cp);
  FutureVoid deleteAll(String uid);
}

class CpAPI implements ICpAPI {
  final Databases _db;
  final Realtime _realtime;
  CpAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> addCp(CpModel cp) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.cpCollection,
        documentId: ID.unique(),
        data: cp.toMap(),
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
  Future<List<Document>> getUserCp(String muridId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.cpCollection,
      queries: [
        Query.equal('muridId', muridId),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokCp(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.cpCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllCp() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.cpCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestCp() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.cpCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateCp(CpModel cp) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.cpCollection,
        documentId: cp.id,
        data: {
          'tujuan': cp.tujuan,
          'tanggal': cp.tanggal,
          'konteks': cp.konteks,
          'teramati': cp.teramati,
          'isDone': cp.isDone,
          'muridId': cp.muridId,
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
  FutureVoid deleteCp(CpModel cp) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.cpCollection,
        documentId: cp.id,
      );
    } catch (e) {
      // print(e.toString());
    }
  }

  @override
  FutureVoid deleteAll(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.cpCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );

    for (int i = 0; i < documents.documents.length; i++) {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.cpCollection,
        documentId: documents.documents[i].$id,
      );
    }
  }
}
