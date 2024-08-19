import 'dart:typed_data';

import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/apis/observasi_api.dart';
import 'package:sippa/apis/users_api.dart';
import 'package:sippa/core/utils.dart';
import 'package:sippa/models/observasi.dart';
import 'package:sippa/auth/controllers/auth_controller.dart';
import 'dart:io' as io;

final observasiControllerProvider =
    StateNotifierProvider<ObservasiController, bool>((ref) {
  return ObservasiController(
    ref: ref,
    observasiAPI: ref.watch(observasiAPIProvider),
  );
});

final getObservasiByUserIdProvider =
    FutureProvider.family((ref, String id) async {
  final observasiController = ref.watch(observasiControllerProvider.notifier);
  final levelUser = ref.watch(currentUserDetailsProvider).value!.levelUser;
  if (levelUser == 1) {
    return observasiController.getAllObservasi();
  } else if (levelUser == 2) {
    return observasiController.getAllObservasi();
  } else {
    return observasiController.getUserObservasi(id);
  }
});
final getUserDataProvider =
    FutureProvider.family<Document, String>((ref, String uid) async {
  final userAPI = ref.watch(userAPIProvider);
  return await userAPI.getUserData(uid);
});

final getLatestObservasiProvider = StreamProvider((ref) {
  final observasiAPI = ref.watch(observasiAPIProvider);
  return observasiAPI.getLatestObservasi();
});

final getObservasiImageProvider =
    FutureProvider.family<Uint8List?, String>((ref, String imageId) async {
  final observasiAPI = ref.watch(observasiAPIProvider);
  return await observasiAPI.getImage(imageId);
});

class ObservasiController extends StateNotifier<bool> {
  final ObservasiAPI _observasiAPI;
  final Ref _ref;
  ObservasiController({
    required Ref ref,
    required ObservasiAPI observasiAPI,
  })  : _ref = ref,
        _observasiAPI = observasiAPI,
        super(false);

  Future<List<ObservasiModel>> getUserObservasi(String uid) async {
    final observasiList = await _observasiAPI.getUserObservasi(uid);
    return observasiList
        .map((observasi) => ObservasiModel.fromMap(observasi.data))
        .toList();
  }

  Future<List<ObservasiModel>> getKelompokObservasi(String kelompok) async {
    final observasiList = await _observasiAPI.getKelompokObservasi(kelompok);
    return observasiList
        .map((observasi) => ObservasiModel.fromMap(observasi.data))
        .toList();
  }

  Future<List<ObservasiModel>> getAllObservasi() async {
    final observasiList = await _observasiAPI.getAllObservasi();
    return observasiList
        .map((observasi) => ObservasiModel.fromMap(observasi.data))
        .toList();
  }

  void addObservasi({
    required String kegiatan,
    required String tanggal,
    required String hasilObservasi,
    required String rekomendasi,
    required io.File? image,
    required String muridId,
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
            await _observasiAPI.uploadFile(image, 'an_${DateTime.now()}.jpg');
      }

      // Create observasi model
      ObservasiModel observasi = ObservasiModel(
        kegiatan: kegiatan,
        tanggal: tanggal,
        hasilObservasi: hasilObservasi,
        rekomendasi: rekomendasi,
        kelompok: kelompok,
        imageId: imageId ?? '',
        muridId: muridId,
        uid: user.id,
        id: '',
        tanggapan: '',
      );

      // Add observasi to the API
      final res = await _observasiAPI.addObservasi(observasi);

      res.fold(
        (l) {
          // Show error message from API
          showSnackBar(context, l.message);
        },
        (r) {
          // Show success message and navigate back
          showSnackBar(context, 'Observasi Added');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      // Handle unexpected errors
      showSnackBar(context, 'Tekan lagi');
    } finally {
      // Set loading state back to false
      state = false;
    }
  }

  void updateObservasi({
    required String observasiId,
    required String kegiatan,
    required String tanggal,
    required String hasilObservasi,
    required String rekomendasi,
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
          await _observasiAPI.deleteImage(imageId);
        }

        imageId =
            await _observasiAPI.uploadFile(image, 'an_${DateTime.now()}.jpg');
      }
      if (deleteId && imageId != '') {
        await _observasiAPI.deleteImage(imageId!);
        imageId = '';
      }

      ObservasiModel observasi = ObservasiModel(
        id: observasiId,
        kegiatan: kegiatan,
        tanggal: tanggal,
        hasilObservasi: hasilObservasi,
        rekomendasi: rekomendasi,
        kelompok: kelompok,
        imageId: imageId ?? '',
        muridId: muridId,
        uid: user.id,
        tanggapan: tanggapan,
      );

      // Update observasi
      final res = await _observasiAPI.updateObservasi(observasi);

      // Handle response
      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) {
          showSnackBar(context, 'Observasi Updated');
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

  void deleteObservasi(
    ObservasiModel observasi,
    BuildContext context,
  ) async {
    try {
      await _observasiAPI.deleteObservasi(observasi);
    } catch (e) {
      // print(e.toString());
    }
  }
}
