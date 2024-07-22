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
  );
});

abstract class IHkAPI {
  FutureEither<Document> addHk(HkModel hk);
  Future<List<Document>> getUserHk(String uid);
  Stream<RealtimeMessage> getLatestHk();
  Future<List<Document>> getKelompokHk(String kelompok);
  Future<List<Document>> getAllHk();
  FutureEither<Document> updateHk(HkModel hk);
  FutureVoid deleteHk(HkModel hk);
  FutureVoid deleteAll(String uid);
}

class HkAPI implements IHkAPI {
  final Databases _db;
  final Realtime _realtime;
  HkAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> addHk(HkModel hk) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.hkCollection,
        documentId: ID.unique(),
        data: hk.toMap(),
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
        data: {
          // 'pengamatan': hk.pengamatan,
          // 'tanggal': hk.tanggal,
          // 'analisisCapaian': hk.analisisCapaian,
          // 'muridId': hk.muridId,
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
