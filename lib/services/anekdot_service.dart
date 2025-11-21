import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/anekdot.dart';

class AnekdotService {
  late final TablesDB _db;
  late final Storage _storage;

  AnekdotService({required TablesDB db, required Storage storage})
    : _db = db,
      _storage = storage;

  Future<Result<AnekdotModel>> createAnekdot(AnekdotModel anekdot) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        rowId: 'unique()',
        data: anekdot.toMap(),
      );

      return Result.success(AnekdotModel.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<AnekdotModel>>> getAllAnekdotBySekolah(
    String sekolah,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('sekolah', sekolah),
        ],
      );
      final anekdotList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return AnekdotModel.fromMap(data);
      }).toList();
      return Result.success(anekdotList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<AnekdotModel>>> getAllAnekdot() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final anekdotList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return AnekdotModel.fromMap(data);
      }).toList();
      return Result.success(anekdotList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<AnekdotModel>>> getAnekdotByGuru(String guruId) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final anekdotList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return AnekdotModel.fromMap(data);
      }).toList();
      return Result.success(anekdotList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<AnekdotModel>> getAnekdotById(String anekdotId) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        rowId: anekdotId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(AnekdotModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<AnekdotModel>> updateAnekdot(AnekdotModel anekdot) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        rowId: anekdot.id,
        data: anekdot.toMap(),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(AnekdotModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteAnekdot(String anekdotId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        rowId: anekdotId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<String?>> uploadAnekdotImage(File file, String userId) async {
    try {
      final result = await _storage.createFile(
        bucketId: dotenv.env['APPWRITE_ANEKDOT_BUCKET_ID']!,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: userId),
      );
      return Result.success(result.$id);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteAnekdotImage(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: dotenv.env['APPWRITE_ANEKDOT_BUCKET_ID']!,
        fileId: fileId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed('Delete failed: $e');
    }
  }

  Future<Result<List<AnekdotModel>>> getAllAnekdotByKelompok(
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        queries: [
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final anekdotList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return AnekdotModel.fromMap(data);
      }).toList();
      return Result.success(anekdotList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<AnekdotModel>>> getAllAnekdotByUId(String id) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_ANEKDOT_COLLECTION_ID']!,
        queries: [Query.equal('muridId', id), Query.orderDesc('\$createdAt')],
      );
      final anekdotList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return AnekdotModel.fromMap(data);
      }).toList();
      return Result.success(anekdotList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  String getPublicImageUrl(String fileId) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    final bucketId = dotenv.env['APPWRITE_ANEKDOT_BUCKET_ID']!;
    return "$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId";
  }
}
