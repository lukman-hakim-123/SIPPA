import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/hk.dart';
import '../services/hk_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'hk_provider.g.dart';

@riverpod
class HkNotifier extends _$HkNotifier {
  late final HkService _hkService = HkService(
    db: ref.read(appwriteTableDBProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<HkModel>> build() async {
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
      final result = await _hkService.getAllHkBySekolah(profile.sekolah);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 2) {
      final result = await _hkService.getAllHkByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 3) {
      final result = await _hkService.getAllHkByUId(profile.id);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _hkService.getAllHk();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createHk(HkModel hk, File photoFile) async {
    state = const AsyncValue.loading();
    try {
      final finalHk = await _uploadPhoto(
        hk,
        hk,
        photoFile: photoFile,
        isCreate: true,
      );

      final result = await _hkService.createHk(finalHk);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Hk: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchHkById(String hkId) async {
    state = const AsyncValue.loading();
    final result = await _hkService.getHkById(hkId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateHk(
    HkModel updatedHk,
    HkModel oldHk,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalHk = await _uploadPhoto(
        oldHk,
        updatedHk,
        photoFile: photoFile,
        isCreate: false,
      );
      final result = await _hkService.updateHk(finalHk);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((hk) {
          return hk.id == finalHk.id ? finalHk : hk;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteHk(HkModel hk) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _hkService.deleteHkImage(hk.imageId);
      final result = await _hkService.deleteHk(hk.id);
      if (!ref.mounted) return;
      if (result.isSuccess) {
        state = AsyncValue.data(previous.where((g) => g.id != hk.id).toList());
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<HkModel> _uploadPhoto(
    HkModel oldHk,
    HkModel updatedHk, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedHk.copyWith(imageId: oldHk.imageId);
    }

    if (!isCreate && photoFile != null && oldHk.imageId.isNotEmpty) {
      try {
        await _hkService.deleteHkImage(oldHk.imageId);
      } catch (_) {}
    }

    final result = await _hkService.uploadHkImage(
      photoFile!,
      'Hk_${updatedHk.id}',
    );

    if (result.isSuccess) {
      return updatedHk.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _hkService.getPublicImageUrl(fileId);
  }
}
