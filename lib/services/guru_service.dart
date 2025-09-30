import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/user.dart';

class GuruService {
  late final TablesDB _db;
  late final Storage _storage;

  GuruService({required TablesDB db, required Storage storage})
    : _db = db,
      _storage = storage;

  Future<Result<User>> createGuru(User user) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        rowId: user.id,
        data: user.toMap(),
      );
      return Result.success(User.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<User>> getGuruById(String userId) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        rowId: userId,
      );
      return Result.success(User.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<User>> updateGuru(User user) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        rowId: user.id,
        data: user.toMap(),
      );

      return Result.success(User.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<String?>> uploadImage(File file, String userId) async {
    try {
      final result = await _storage.createFile(
        bucketId: dotenv.env['APPWRITE_HK_BUCKET_ID']!,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: userId),
      );
      return Result.success(result.$id);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteImage(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: dotenv.env['APPWRITE_HK_BUCKET_ID']!,
        fileId: fileId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed('Delete failed: $e');
    }
  }

  Future<Result<List<User>>> getAllGuruBySekolah(String sekolah) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        queries: [
          Query.equal('levelUser', 2),
          Query.equal('sekolah', sekolah),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final guruList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return User.fromMap(data);
      }).toList();
      return Result.success(guruList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<User>>> getAllGuru() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        queries: [Query.equal('levelUser', 2), Query.orderDesc('\$createdAt')],
      );
      final guruList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return User.fromMap(data);
      }).toList();
      return Result.success(guruList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteGuru(String guruId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        rowId: guruId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  String getPublicImageUrl(String fileId) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    final bucketId = dotenv.env['APPWRITE_HK_BUCKET_ID']!;
    return "$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId";
  }
}
