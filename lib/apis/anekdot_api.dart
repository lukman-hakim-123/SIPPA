import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/anekdot.dart';

final anekdotAPIProvider = Provider((ref) {
  return AnekdotAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
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
}

class AnekdotAPI implements IAnekdotAPI {
  final Databases _db;
  final Realtime _realtime;
  AnekdotAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

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
  Future<List<Document>> getKelompokAnekdot(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.anekdotCollection,
      queries: [
        Query.equal('uid', uid),
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
          'analisisCapaian': anekdot.analisisCapaian,
          'muridId': anekdot.muridId,
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
