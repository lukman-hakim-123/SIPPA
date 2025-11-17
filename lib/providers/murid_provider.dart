import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user.dart';
import '../services/auth_service.dart';
import '../services/murid_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'murid_provider.g.dart';

@Riverpod(keepAlive: true)
class MuridNotifier extends _$MuridNotifier {
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );
  late final MuridService _muridService = MuridService(
    db: ref.read(appwriteTableDBProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<User>> build() async {
    final profileAsync = ref.watch(userProvider);

    if (profileAsync.isLoading) {
      state = const AsyncValue.loading();
    }
    if (profileAsync.hasError) {
      throw profileAsync.error!;
    }

    final profile = profileAsync.value;
    if (profile == null) return [];

    final level = profile.levelUser;
    if (level == 1) {
      final result = await _muridService.getAllMuridBySekolah(profile.sekolah);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 2) {
      final result = await _muridService.getAllMuridByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _muridService.getAllMurid();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createMurid(
    String nama,
    String email,
    String password,
    String sekolah,
    String kelompok,
    File photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authResult = await _authService.createAccount(
        email: email,
        password: password,
      );

      if (!authResult.isSuccess) {
        throw Exception("Gagal membuat akun Murid: ${authResult.errorMessage}");
      }

      final userId = authResult.resultValue?.$id ?? '';
      if (userId.isEmpty) {
        throw Exception("User ID dari Appwrite kosong");
      }

      final muridProfile = User(
        id: userId,
        nama: nama,
        email: email,
        imageId: '',
        levelUser: 3,
        sekolah: sekolah,
        kelompok: kelompok,
      );

      final finalMurid = await _uploadPhoto(
        muridProfile,
        muridProfile,
        photoFile: photoFile,
        isCreate: true,
      );

      final result = await _muridService.createMurid(finalMurid);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Murid: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchMuridById(String muridId) async {
    state = const AsyncValue.loading();
    final result = await _muridService.getMuridById(muridId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateMurid(
    User updatedMurid,
    User oldMurid,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalMurid = await _uploadPhoto(
        oldMurid,
        updatedMurid,
        photoFile: photoFile,
        isCreate: false,
      );
      final result = await _muridService.updateMurid(finalMurid);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((murid) {
          return murid.id == finalMurid.id ? finalMurid : murid;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteMurid(User murid) async {
    final previous = state.value ?? [];

    try {
      await _muridService.deleteImage(murid.imageId);
      final result = await _muridService.deleteMurid(murid.id);
      if (!ref.mounted) return;

      if (result.isSuccess) {
        // Hanya update data, jangan set loading
        state = AsyncValue.data(
          previous.where((g) => g.id != murid.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<User> _uploadPhoto(
    User oldMurid,
    User updatedMurid, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedMurid.copyWith(imageId: oldMurid.imageId);
    }

    if (!isCreate && photoFile != null && oldMurid.imageId.isNotEmpty) {
      try {
        await _muridService.deleteImage(oldMurid.imageId);
      } catch (_) {}
    }

    final result = await _muridService.uploadImage(
      photoFile!,
      'Murid_${updatedMurid.email}',
    );

    if (result.isSuccess) {
      return updatedMurid.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _muridService.getPublicImageUrl(fileId);
  }
}
