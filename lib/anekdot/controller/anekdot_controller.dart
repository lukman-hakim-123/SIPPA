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
    FutureProvider.family((ref, String id) async {
  final anekdotController = ref.watch(anekdotControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return anekdotController.getAllAnekdot();
  } else if (levelUser == 2) {
    return anekdotController.getAllAnekdot();
  } else {
    return anekdotController.getUserAnekdot(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestAnekdotProvider = StreamProvider((ref) {
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

  Future<List<AnekdotModel>> getUserAnekdot(String uid) async {
    final anekdotList = await _anekdotAPI.getUserAnekdot(uid);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getKelompokAnekdot(String kelompok) async {
    final anekdotList = await _anekdotAPI.getKelompokAnekdot(kelompok);
    return anekdotList
        .map((anekdot) => AnekdotModel.fromMap(anekdot.data))
        .toList();
  }

  Future<List<AnekdotModel>> getAllAnekdot() async {
    final anekdotList = await _anekdotAPI.getAllAnekdot();
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

      // Upload image if provided
      if (image != null) {
        imageId =
            await _anekdotAPI.uploadFile(image, 'an_${DateTime.now()}.jpg');
      }

      // Create anekdot model
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
          tujuan: tujuan);

      // Add anekdot to the API
      final res = await _anekdotAPI.addAnekdot(anekdot);

      res.fold(
        (l) {
          // Show error message from API
          showSnackBar(context, l.message);
        },
        (r) {
          // Show success message and navigate back
          showSnackBar(context, 'Anekdot Added');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      // Handle unexpected errors
      showSnackBar(context, 'Terjadi kesalahan: $e');
    } finally {
      // Set loading state back to false
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
    required BuildContext context,
  }) async {
    state = true;
    try {
      final user = _ref.read(currentUserDetailsProvider).value!;
      final kelompok = _ref.read(searchUserProvider(muridId)).value!.kelompok;

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
      );

      // Update anekdot
      final res = await _anekdotAPI.updateAnekdot(anekdot);

      // Handle response
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
      // Handle unexpected errors
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
