import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/rubrik.dart';

final rubrikAPIProvider = Provider((ref) {
  return RubrikAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class IRubrikAPI {
  FutureEither<Document> addRubrik(RubrikModel rubrik);
  Future<List<Document>> getUserRubrik(String uid, String sekolah);
  Stream<RealtimeMessage> getLatestRubrik();
  Future<List<Document>> getKelompokRubrik(String kelompok, String sekolah);
  Future<List<Document>> getAllRubrik(String sekolah);
  FutureEither<Document> updateRubrik(RubrikModel rubrik);
  FutureVoid deleteRubrik(RubrikModel rubrik);
  FutureVoid deleteAll(String uid, String sekolah);
}

class RubrikAPI implements IRubrikAPI {
  final Databases _db;
  final Realtime _realtime;
  RubrikAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> addRubrik(RubrikModel rubrik) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.rubrikCollection,
        documentId: ID.unique(),
        data: rubrik.toMap(), // pastikan di toMap() sudah ada field 'sekolah'
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getUserRubrik(String muridId, String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.rubrikCollection,
      queries: [
        Query.equal('muridId', muridId),
        Query.equal('sekolah', sekolah),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokRubrik(String uid, String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.rubrikCollection,
      queries: [Query.equal('uid', uid), Query.equal('sekolah', sekolah)],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllRubrik(String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.rubrikCollection,
      queries: [Query.equal('sekolah', sekolah)],
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestRubrik() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.rubrikCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updateRubrik(RubrikModel rubrik) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.rubrikCollection,
        documentId: rubrik.id,
        data: rubrik.toMap(), // pastikan 'sekolah' tetap dikirim
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? 'Some unexpected error occurred', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureVoid deleteRubrik(RubrikModel rubrik) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.rubrikCollection,
        documentId: rubrik.id,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  FutureVoid deleteAll(String uid, String sekolah) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.rubrikCollection,
      queries: [Query.equal('uid', uid), Query.equal('sekolah', sekolah)],
    );

    for (int i = 0; i < documents.documents.length; i++) {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.rubrikCollection,
        documentId: documents.documents[i].$id,
      );
    }
  }
}
