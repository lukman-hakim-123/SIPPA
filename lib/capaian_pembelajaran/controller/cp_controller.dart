import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/cp_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/cp.dart';

final cpControllerProvider = StateNotifierProvider<CpController, bool>((ref) {
  return CpController(
    ref: ref,
    cpAPI: ref.watch(cpAPIProvider),
  );
});

final getCpByUserIdProvider = FutureProvider.family((ref, String id) async {
  final cpController = ref.watch(cpControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return cpController.getAllCp();
  } else if (levelUser == 2) {
    return cpController.getAllCp();
  } else {
    return cpController.getUserCp(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestCpProvider = StreamProvider((ref) {
  final cpAPI = ref.watch(cpAPIProvider);
  return cpAPI.getLatestCp();
});

class CpController extends StateNotifier<bool> {
  final CpAPI _cpAPI;
  final Ref _ref;
  CpController({
    required Ref ref,
    required CpAPI cpAPI,
  })  : _ref = ref,
        _cpAPI = cpAPI,
        super(false);

  Future<List<CpModel>> getUserCp(String uid) async {
    final cpList = await _cpAPI.getUserCp(uid);
    return cpList.map((cp) => CpModel.fromMap(cp.data)).toList();
  }

  Future<List<CpModel>> getKelompokCp(String kelompok) async {
    final cpList = await _cpAPI.getKelompokCp(kelompok);
    return cpList.map((cp) => CpModel.fromMap(cp.data)).toList();
  }

  Future<List<CpModel>> getAllCp() async {
    final cpList = await _cpAPI.getAllCp();
    return cpList.map((cp) => CpModel.fromMap(cp.data)).toList();
  }

  void addCp({
    required String tujuan,
    required String tanggal,
    required String konteks,
    required String teramati,
    required bool isDone,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value!.kelompok;
    CpModel cp = CpModel(
      tujuan: tujuan,
      tanggal: tanggal,
      konteks: konteks,
      teramati: teramati,
      isDone: isDone,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
      id: '',
    );
    final res = await _cpAPI.addCp(cp);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Capaian Pembelajaran Added');
      Navigator.pop(context);
    });
  }

  void updateCp({
    required String cpId,
    required String tujuan,
    required String tanggal,
    required String konteks,
    required String teramati,
    required bool isDone,
    required String muridId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value!.kelompok;

    CpModel cp = CpModel(
      id: cpId,
      tujuan: tujuan,
      tanggal: tanggal,
      konteks: konteks,
      teramati: teramati,
      isDone: isDone,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
    );
    final res = await _cpAPI.updateCp(cp);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Capaian Pembelajaran Updated');
      Navigator.pop(context);
    });
  }

  void deleteCp(
    CpModel cp,
    BuildContext context,
  ) async {
    try {
      await _cpAPI.deleteCp(cp);
    } catch (e) {
      // print(e.toString());
    }
  }
}
