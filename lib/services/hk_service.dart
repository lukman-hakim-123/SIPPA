// HASIL KARYA

import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/hk.dart';

class HkService {
  late final TablesDB _db;
  late final Storage _storage;

  HkService({required TablesDB db, required Storage storage})
    : _db = db,
      _storage = storage;

  Future<Result<HkModel>> createHk(HkModel hk) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        rowId: 'unique()',
        data: hk.toMap(),
      );

      return Result.success(HkModel.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HkModel>>> getAllHkBySekolah(String sekolah) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('sekolah', sekolah),
        ],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HkModel>>> getAllHk() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HkModel>>> getHkByEmail(String email) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [Query.equal('email', email), Query.orderDesc("\$createdAt")],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HkModel>>> getHkByGuru(String guruId) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<HkModel>> getHkById(String hkId) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        rowId: hkId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(HkModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<HkModel>> updateHk(HkModel hk) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        rowId: hk.id,
        data: hk.toMap(),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(HkModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteHk(String hkId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        rowId: hkId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<String?>> uploadHkImage(File file, String userId) async {
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

  Future<Result<void>> deleteHkImage(String fileId) async {
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

  Future<Result<List<HkModel>>> getAllHkByKelompok(
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HkModel>>> getAllHkByUId(
    String id,
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_HK_COLLECTION_ID']!,
        queries: [
          Query.equal('muridId', id),
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final hkList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return HkModel.fromMap(data);
      }).toList();
      return Result.success(hkList);
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
