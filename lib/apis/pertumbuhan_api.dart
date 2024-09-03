import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/failure.dart';
import 'package:sippa/core/providers.dart';
import 'package:sippa/core/type_defs.dart';
import 'package:sippa/models/pertumbuhan.dart';

final pertumbuhanAPIProvider = Provider((ref) {
  return PertumbuhanAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class IPertumbuhanAPI {
  FutureEither<Document> addPertumbuhan(PertumbuhanModel pertumbuhan);
  Future<List<Document>> getUserPertumbuhan(String uid);
  Stream<RealtimeMessage> getLatestPertumbuhan();
  Future<List<Document>> getKelompokPertumbuhan(String kelompok);
  Future<List<Document>> getAllPertumbuhan();
  FutureEither<Document> updatePertumbuhan(PertumbuhanModel pertumbuhan);
  FutureVoid deletePertumbuhan(PertumbuhanModel pertumbuhan);
  FutureVoid deleteAll(String uid);
}

class PertumbuhanAPI implements IPertumbuhanAPI {
  final Databases _db;
  final Realtime _realtime;

  PertumbuhanAPI({
    required Databases db,
    required Realtime realtime,
  })  : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> addPertumbuhan(PertumbuhanModel pertumbuhan) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.pertumbuhanCollection,
        documentId: ID.unique(),
        data: pertumbuhan.toMap(),
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
  Future<List<Document>> getUserPertumbuhan(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pertumbuhanCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getKelompokPertumbuhan(String kelompok) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pertumbuhanCollection,
      queries: [
        Query.equal('kelompok', kelompok),
      ],
    );
    return documents.documents;
  }

  @override
  Future<List<Document>> getAllPertumbuhan() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pertumbuhanCollection,
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestPertumbuhan() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.pertumbuhanCollection}.documents',
    ]).stream;
  }

  @override
  FutureEither<Document> updatePertumbuhan(PertumbuhanModel pertumbuhan) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.pertumbuhanCollection,
        documentId: pertumbuhan.id,
        data: pertumbuhan.toMap(),
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
  FutureVoid deletePertumbuhan(PertumbuhanModel pertumbuhan) async {
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.pertumbuhanCollection,
        documentId: pertumbuhan.id,
      );
    } catch (e) {
      // Handle or log error
    }
  }

  @override
  FutureVoid deleteAll(String uid) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.pertumbuhanCollection,
      queries: [
        Query.equal('uid', uid),
      ],
    );

    for (final doc in documents.documents) {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.pertumbuhanCollection,
        documentId: doc.$id,
      );
    }
  }
}