import 'dart:convert';
import 'dart:typed_data';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/anekdot_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/anekdot.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'dart:io' as io;

final anekdotControllerProvider =
    StateNotifierProvider<AnekdotController, bool>((ref) {
  return AnekdotController(
    ref: ref,
    anekdotAPI: ref.watch(anekdotAPIProvider),
  );
});

final getAnekdotByUserIdProvider =
    FutureProvider.family<List<AnekdotModel>, String>((ref, paramKey) async {
  final anekdotController = ref.watch(anekdotControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  final params = jsonDecode(paramKey) as Map<String, dynamic>;
  final sekolah = params['sekolah'] as String;
  final id = params['id'] as String;

  if (levelUser == 1) {
    return anekdotController.getAllAnekdot(sekolah);
  } else if (levelUser == 2) {
    return anekdotController.getAllAnekdot(sekolah);
  } else {
    return anekdotController.getUserAnekdot(id, sekolah);
  }
});

final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestAnekdotProvider = StreamProvider((ref) {
  ref.keepAlive();
  final anekdotAPI = ref.watch(anekdotAPIProvider);
  return anekdotAPI.getLatestAnekdot();
});

final getAnekdotImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final anekdotAPI = ref.watch(anekdotAPIProvider);
  return await anekdotAPI.getImage(imageId);
});

class AnekdotController extends StateNotifier<bool> {
  final AnekdotAPI _anekdotAPI;
  final Ref _ref;
  AnekdotController({
    required Ref ref,
    required AnekdotAPI anekdotAPI,
  })  : _ref = ref,
        _anekdotAPI = anekdotAPI,
        super(false);

  Future<List<AnekdotModel>> getUserAnekdot(String uid, String sekolah) async {
    final anekdotList = await _anekdotAPI.getUserAnekdot(uid, sekolah);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getKelompokAnekdot(
      String kelompok, String sekolah) async {
    final anekdotList = await _anekdotAPI.getKelompokAnekdot(kelompok, sekolah);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getAllAnekdot(String sekolah) async {
    final anekdotList = await _anekdotAPI.getAllAnekdot(sekolah);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  void addAnekdot({
    required String pengamatan,
    required String tujuan,
    required String tanggal,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required String umpanBalik,
    required io.File? image,
    required String muridId,
    required String tanggapan,
    required String sekolah, // ✅ ditambahkan
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserDetailsProvider).value;
      if (user == null) {
        showSnackBar(context, 'User details not available');
        state = false;
        return;
      }

      final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
      if (kelompok == null) {
        showSnackBar(context, 'Tekan lagi');
        state = false;
        return;
      }
      String? imageId;

      if (image != null) {
        imageId =
            await _anekdotAPI.uploadFile(image, 'an_${DateTime.now()}.jpg');
      }

      AnekdotModel anekdot = AnekdotModel(
        pengamatan: pengamatan,
        tanggal: tanggal,
        nilai: nilai,
        jatiDiri: jatiDiri,
        literasi: literasi,
        umpanBalik: umpanBalik,
        kelompok: kelompok,
        imageId: imageId ?? '',
        muridId: muridId,
        uid: user.id,
        id: '',
        tanggapan: '',
        tujuan: tujuan,
        sekolah: sekolah, // ✅ dimasukkan ke model
      );

      final res = await _anekdotAPI.addAnekdot(anekdot);

      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) {
          showSnackBar(context, 'Anekdot Added');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Terjadi kesalahan: $e');
    } finally {
      state = false;
    }
  }

  void updateAnekdot({
    required String anekdotId,
    required String pengamatan,
    required String tujuan,
    required String tanggal,
    required String nilai,
    required String jatiDiri,
    required String literasi,
    required String umpanBalik,
    required io.File? image,
    required String? imageId,
    required bool deleteId,
    required String muridId,
    required String tanggapan,
    required String sekolah, // ✅ ditambahkan
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserDetailsProvider).value!;
      final kelompok = _ref.read(searchUserProvider(muridId)).value?.kelompok;
      if (kelompok == null) {
        showSnackBar(context, 'Tekan lagi');
        state = false;
        return;
      }
      if (image != null) {
        if (imageId != null && imageId.isNotEmpty) {
          await _anekdotAPI.deleteImage(imageId);
        }
        imageId =
            await _anekdotAPI.uploadFile(image, 'an_${DateTime.now()}.jpg');
      }
      if (deleteId && imageId != '') {
        await _anekdotAPI.deleteImage(imageId!);
        imageId = '';
      }

      AnekdotModel anekdot = AnekdotModel(
        id: anekdotId,
        pengamatan: pengamatan,
        tanggal: tanggal,
        nilai: nilai,
        jatiDiri: jatiDiri,
        literasi: literasi,
        umpanBalik: umpanBalik,
        kelompok: kelompok,
        imageId: imageId ?? '',
        muridId: muridId,
        uid: user.id,
        tanggapan: tanggapan,
        tujuan: tujuan,
        sekolah: sekolah, // ✅ dimasukkan ke model
      );

      final res = await _anekdotAPI.updateAnekdot(anekdot);

      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) {
          showSnackBar(context, 'Anekdot Updated');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      showSnackBar(context, 'Tekan lagi');
    } finally {
      state = false;
    }
  }

  void deleteAnekdot(
    AnekdotModel anekdot,
    BuildContext context,
  ) async {
    try {
      await _anekdotAPI.deleteAnekdot(anekdot);
    } catch (e) {
      // print(e.toString());
    }
  }
}
