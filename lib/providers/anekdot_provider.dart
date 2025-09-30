import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/anekdot.dart';
import '../services/anekdot_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'anekdot_provider.g.dart';

@riverpod
class AnekdotNotifier extends _$AnekdotNotifier {
  late final AnekdotService _anekdotService = AnekdotService(
    db: ref.read(appwriteTableDBProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<AnekdotModel>> build() async {
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
      final result = await _anekdotService.getAllAnekdotBySekolah(
        profile.sekolah,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 2) {
      final result = await _anekdotService.getAllAnekdotByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 3) {
      final result = await _anekdotService.getAllAnekdotByUId(
        profile.id,
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _anekdotService.getAllAnekdot();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createAnekdot(AnekdotModel anekdot, File photoFile) async {
    state = const AsyncValue.loading();
    try {
      final finalAnekdot = await _uploadPhoto(
        anekdot,
        anekdot,
        photoFile: photoFile,
        isCreate: true,
      );

      final result = await _anekdotService.createAnekdot(finalAnekdot);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Anekdot: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchAnekdotById(String anekdotId) async {
    state = const AsyncValue.loading();
    final result = await _anekdotService.getAnekdotById(anekdotId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateAnekdot(
    AnekdotModel updatedAnekdot,
    AnekdotModel oldAnekdot,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalAnekdot = await _uploadPhoto(
        oldAnekdot,
        updatedAnekdot,
        photoFile: photoFile,
        isCreate: false,
      );
      final result = await _anekdotService.updateAnekdot(finalAnekdot);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((anekdot) {
          return anekdot.id == finalAnekdot.id ? finalAnekdot : anekdot;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteAnekdot(AnekdotModel anekdot) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _anekdotService.deleteAnekdotImage(anekdot.imageId);
      final result = await _anekdotService.deleteAnekdot(anekdot.id);
      if (!ref.mounted) return;
      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((g) => g.id != anekdot.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AnekdotModel> _uploadPhoto(
    AnekdotModel oldAnekdot,
    AnekdotModel updatedAnekdot, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedAnekdot.copyWith(imageId: oldAnekdot.imageId);
    }

    if (!isCreate && photoFile != null && oldAnekdot.imageId.isNotEmpty) {
      try {
        await _anekdotService.deleteAnekdotImage(oldAnekdot.imageId);
      } catch (_) {}
    }

    final result = await _anekdotService.uploadAnekdotImage(
      photoFile!,
      'Anekdot_${updatedAnekdot.id}',
    );

    if (result.isSuccess) {
      return updatedAnekdot.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _anekdotService.getPublicImageUrl(fileId);
  }
}
