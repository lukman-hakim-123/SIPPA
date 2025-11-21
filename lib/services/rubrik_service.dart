import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/rubrik.dart';

class RubrikService {
  late final TablesDB _db;

  RubrikService({required TablesDB db}) : _db = db;

  Future<Result<RubrikModel>> createRubrik(RubrikModel rubrik) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        rowId: 'unique()',
        data: rubrik.toMap(),
      );

      return Result.success(RubrikModel.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<RubrikModel>>> getAllRubrikBySekolah(
    String sekolah,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('sekolah', sekolah),
        ],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return RubrikModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<RubrikModel>>> getAllRubrik() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return RubrikModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<RubrikModel>>> getRubrikByGuru(String guruId) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return RubrikModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<RubrikModel>> getRubrikById(String rubrikId) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        rowId: rubrikId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(RubrikModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<RubrikModel>> updateRubrik(RubrikModel rubrik) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        rowId: rubrik.id,
        data: rubrik.toMap(),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(RubrikModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteRubrik(String rubrikId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        rowId: rubrikId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<RubrikModel>>> getAllRubrikByKelompok(
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        queries: [
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return RubrikModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<RubrikModel>>> getAllRubrikByUId(String id) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_RUBRIK_COLLECTION_ID']!,
        queries: [Query.equal('muridId', id), Query.orderDesc('\$createdAt')],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return RubrikModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
