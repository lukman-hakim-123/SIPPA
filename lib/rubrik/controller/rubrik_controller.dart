import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/rubrik_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'package:sippa/models/rubrik.dart';

final rubrikControllerProvider =
    StateNotifierProvider<RubrikController, bool>((ref) {
  return RubrikController(
    ref: ref,
    rubrikAPI: ref.watch(rubrikAPIProvider),
  );
});

final getRubrikByUserIdProvider = FutureProvider.family((ref, String id) async {
  final rubrikController = ref.watch(rubrikControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return rubrikController.getAllRubrik();
  } else if (levelUser == 2) {
    return rubrikController.getAllRubrik();
  } else {
    return rubrikController.getUserRubrik(id);
  }
});

final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestRubrikProvider = StreamProvider((ref) {
  final rubrikAPI = ref.watch(rubrikAPIProvider);
  return rubrikAPI.getLatestRubrik();
});

class RubrikController extends StateNotifier<bool> {
  final RubrikAPI _rubrikAPI;
  final Ref _ref;
  RubrikController({
    required Ref ref,
    required RubrikAPI rubrikAPI,
  })  : _ref = ref,
        _rubrikAPI = rubrikAPI,
        super(false);

  Future<List<RubrikModel>> getUserRubrik(String uid) async {
    final rubrikList = await _rubrikAPI.getUserRubrik(uid);
    return rubrikList
        .map((rubrik) => RubrikModel.fromMap(rubrik.data))
        .toList();
  }

  Future<List<RubrikModel>> getKelompokRubrik(String kelompok) async {
    final rubrikList = await _rubrikAPI.getKelompokRubrik(kelompok);
    return rubrikList
        .map((rubrik) => RubrikModel.fromMap(rubrik.data))
        .toList();
  }

  Future<List<RubrikModel>> getAllRubrik() async {
    final rubrikList = await _rubrikAPI.getAllRubrik();
    return rubrikList
        .map((rubrik) => RubrikModel.fromMap(rubrik.data))
        .toList();
  }

  void addRubrik({
    required String tujuan,
    required String tanggal,
    // required String kegiatan,
    required String agama,
    required String jatidiri,
    required String literasi,
    required String skor,
    required String muridId,
    required String rekomendasi,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
    if (kelompok == null) {
      showSnackBar(context, 'Tekan lagi');
      state = false;
      return;
    }
    RubrikModel rubrik = RubrikModel(
      tujuan: tujuan,
      tanggal: tanggal,
      // kegiatan: kegiatan,
      kegiatan: '',
      agama: agama,
      jatidiri: jatidiri,
      literasi: literasi,
      skor: skor,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
      id: '',
      rekomendasi: rekomendasi,
      tanggapan: '',
    );
    final res = await _rubrikAPI.addRubrik(rubrik);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Rubrik Added');
      Navigator.pop(context);
    });
  }

  void updateRubrik({
    required String rubrikId,
    required String tujuan,
    required String tanggal,
    // required String kegiatan,
    required String agama,
    required String jatidiri,
    required String literasi,
    required String skor,
    required String muridId,
    required String rekomendasi,
    required String tanggapan,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(currentUserDetailsProvider).value!;
    final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
    if (kelompok == null) {
      showSnackBar(context, 'Tekan lagi');
      state = false;
      return;
    }
    RubrikModel rubrik = RubrikModel(
      id: rubrikId,
      tujuan: tujuan,
      tanggal: tanggal,
      // kegiatan: kegiatan,
      kegiatan: '',
      agama: agama,
      jatidiri: jatidiri,
      literasi: literasi,
      skor: skor,
      muridId: muridId,
      kelompok: kelompok,
      uid: user.id,
      rekomendasi: rekomendasi,
      tanggapan: tanggapan,
    );
    final res = await _rubrikAPI.updateRubrik(rubrik);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Rubrik Updated');
      Navigator.pop(context);
    });
  }

  void deleteRubrik(
    RubrikModel rubrik,
    BuildContext context,
  ) async {
    try {
      await _rubrikAPI.deleteRubrik(rubrik);
    } catch (e) {
      // print(e.toString());
    }
  }
}
