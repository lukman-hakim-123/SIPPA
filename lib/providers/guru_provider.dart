import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/user.dart';
import '../services/auth_service.dart';
import '../services/guru_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'guru_provider.g.dart';

@riverpod
class GuruNotifier extends _$GuruNotifier {
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );
  late final GuruService _guruService = GuruService(
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
      final result = await _guruService.getAllGuruBySekolah(profile.sekolah);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _guruService.getAllGuru();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createGuru(
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
        throw Exception("Gagal membuat akun guru: ${authResult.errorMessage}");
      }

      final userId = authResult.resultValue?.$id ?? '';
      if (userId.isEmpty) {
        throw Exception("User ID dari Appwrite kosong");
      }

      final guruProfile = User(
        id: userId,
        nama: nama,
        email: email,
        imageId: '',
        levelUser: 2,
        sekolah: sekolah,
        kelompok: kelompok,
      );

      final finalGuru = await _uploadPhoto(
        guruProfile,
        guruProfile,
        photoFile: photoFile,
        isCreate: true,
      );

      final result = await _guruService.createGuru(finalGuru);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan guru: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchGuruById(String guruId) async {
    state = const AsyncValue.loading();
    final result = await _guruService.getGuruById(guruId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateGuru(
    User updatedGuru,
    User oldGuru,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalGuru = await _uploadPhoto(
        oldGuru,
        updatedGuru,
        photoFile: photoFile,
        isCreate: false,
      );
      final result = await _guruService.updateGuru(finalGuru);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((guru) {
          return guru.id == finalGuru.id ? finalGuru : guru;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteGuru(User guru) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _guruService.deleteImage(guru.imageId);
      final result = await _guruService.deleteGuru(guru.id);
      if (!ref.mounted) return;

      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((g) => g.id != guru.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<User> _uploadPhoto(
    User oldGuru,
    User updatedGuru, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedGuru.copyWith(imageId: oldGuru.imageId);
    }

    if (!isCreate && photoFile != null && oldGuru.imageId.isNotEmpty) {
      try {
        await _guruService.deleteImage(oldGuru.imageId);
      } catch (_) {}
    }

    final result = await _guruService.uploadImage(
      photoFile!,
      'guru_${updatedGuru.email}',
    );

    if (result.isSuccess) {
      return updatedGuru.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _guruService.getPublicImageUrl(fileId);
  }
}
