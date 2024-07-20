import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/core/providers.dart';
import '../core/failure.dart';
import '../core/type_defs.dart';
import '../models/user.dart';

final userAPIProvider = Provider((ref) {
  return UserAPI(
      db: ref.watch(appwriteDatabaseProvider),
      realtime: ref.watch(appwriteRealtimeProvider));
});

abstract class IUserAPI {
  FutureEitherVoid saveUserData(User userModel);
  Future<model.Document> getUserData(String uid);
  Future<List<model.Document>> getAllMurid(String kelompok);
  Stream<RealtimeMessage> getLatestMurid();
  Future<List<model.Document>> getAllGuru();
}

class UserAPI implements IUserAPI {
  final Databases _db;
  final Realtime _realtime;
  UserAPI({required Databases db, required Realtime realtime})
      : _db = db,
        _realtime = realtime;

  @override
  FutureEitherVoid saveUserData(User userModel) async {
    try {
      await _db.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.collectionUserId,
          documentId: userModel.id,
          data: userModel.toMap());
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<model.Document> getUserData(String uid) async {
    return await _db.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.collectionUserId,
        documentId: uid);
  }

  @override
  Future<List<model.Document>> getAllMurid(String kelompok) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionUserId,
      queries: [
        Query.equal('levelUser', 3),
        Query.equal('kelompok', kelompok),
      ],
    );
    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestMurid() {
    return _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.collectionUserId}.documents',
    ]).stream;
  }

  @override
  Future<List<model.Document>> getAllGuru() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.collectionUserId,
      queries: [
        Query.equal('levelUser', 2),
      ],
    );
    return documents.documents;
  }
}
