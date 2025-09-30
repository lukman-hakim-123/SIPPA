import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/pertumbuhan.dart';

class PertumbuhanService {
  late final TablesDB _db;

  PertumbuhanService({required TablesDB db}) : _db = db;

  Future<Result<PertumbuhanModel>> createPertumbuhan(
    PertumbuhanModel pertumbuhan,
  ) async {
    try {
      final document = await _db.createRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        rowId: 'unique()',
        data: pertumbuhan.toMap(),
      );

      return Result.success(PertumbuhanModel.fromMap(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<PertumbuhanModel>>> getAllPertumbuhanBySekolah(
    String sekolah,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [
          Query.orderDesc("\$createdAt"),
          Query.equal('sekolah', sekolah),
        ],
      );
      final pertumbuhanList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return PertumbuhanModel.fromMap(data);
      }).toList();
      return Result.success(pertumbuhanList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<PertumbuhanModel>>> getAllPertumbuhan() async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final pertumbuhanList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return PertumbuhanModel.fromMap(data);
      }).toList();
      return Result.success(pertumbuhanList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<PertumbuhanModel>>> getPertumbuhanByGuru(
    String guruId,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final pertumbuhanList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return PertumbuhanModel.fromMap(data);
      }).toList();
      return Result.success(pertumbuhanList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<PertumbuhanModel>> getPertumbuhanById(
    String pertumbuhanId,
  ) async {
    try {
      final document = await _db.getRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        rowId: pertumbuhanId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(PertumbuhanModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<PertumbuhanModel>> updatePertumbuhan(
    PertumbuhanModel pertumbuhan,
  ) async {
    try {
      final document = await _db.updateRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        rowId: pertumbuhan.id,
        data: pertumbuhan.toMap(),
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      return Result.success(PertumbuhanModel.fromMap(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateEmailForPertumbuhan(
    String oldEmail,
    String newEmail,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [Query.equal('email', oldEmail)],
      );

      for (final doc in documents.rows) {
        await _db.updateRow(
          databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
          tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
          rowId: doc.$id,
          data: {'email': newEmail},
        );
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deletePertumbuhan(String pertumbuhanId) async {
    try {
      await _db.deleteRow(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        rowId: pertumbuhanId,
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<PertumbuhanModel>>> getAllPertumbuhanByKelompok(
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return PertumbuhanModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<PertumbuhanModel>>> getAllPertumbuhanByUId(
    String id,
    String sekolah,
    kelompok,
  ) async {
    try {
      final documents = await _db.listRows(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        tableId: dotenv.env['APPWRITE_PERTUMBUHAN_COLLECTION_ID']!,
        queries: [
          Query.equal('muridId', id),
          Query.equal('sekolah', sekolah),
          Query.equal('kelompok', kelompok),
          Query.orderDesc('\$createdAt'),
        ],
      );
      final rubrikList = documents.rows.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        return PertumbuhanModel.fromMap(data);
      }).toList();
      return Result.success(rubrikList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
