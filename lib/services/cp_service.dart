// CAPAIAN PEMBELAJARAN

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/cp.dart';

class CpService {
  late final TablesDB _db;

  CpService({required TablesDB db}) : _db = db;

  Future<Result<CpModel>> createCp(CpModel cp) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        rowId: 'unique()',
        data: cp.toMap(),
      );

      return Result.success(CpModel.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<CpModel>>> getAllCpBySekolah(String sekolah) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('sekolah', sekolah),
        ],
      );
      final cpList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return CpModel.fromMap(data);
      }).toList();
      return Result.success(cpList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<CpModel>>> getAllCp() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final cpList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return CpModel.fromMap(data);
      }).toList();
      return Result.success(cpList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<CpModel>>> getCpByGuru(String guruId) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final cpList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return CpModel.fromMap(data);
      }).toList();
      return Result.success(cpList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<CpModel>> getCpById(String cpId) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        rowId: cpId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(CpModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<CpModel>> updateCp(CpModel cp) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        rowId: cp.id,
        data: cp.toMap(),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(CpModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateEmailForCp(
    String oldEmail,
    String newEmail,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [Query.equal('email', oldEmail)],
      );

      for (final doc in documents.rows) {
        await _db.updateRow(
          databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
          tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
          rowId: doc.$id,
          data: {'email': newEmail},
        );
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteCp(String cpId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        rowId: cpId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<CpModel>>> getAllCpByKelompok(
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final cpList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return CpModel.fromMap(data);
      }).toList();
      return Result.success(cpList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<CpModel>>> getAllCpByUId(String id) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_CP_COLLECTION_ID']!,
        queries: [Query.equal('muridId', id), Query.orderDesc('\$createdAt')],
      );
      final cpList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return CpModel.fromMap(data);
      }).toList();
      return Result.success(cpList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
