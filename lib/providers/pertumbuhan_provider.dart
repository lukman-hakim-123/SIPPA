import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/pertumbuhan.dart';
import '../services/pertumbuhan_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'pertumbuhan_provider.g.dart';

@riverpod
class PertumbuhanNotifier extends _$PertumbuhanNotifier {
  late final PertumbuhanService _pertumbuhanService = PertumbuhanService(
    db: ref.read(appwriteTableDBProvider),
  );

  @override
  Future<List<PertumbuhanModel>> build() async {
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
      final result = await _pertumbuhanService.getAllPertumbuhanBySekolah(
        profile.sekolah,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 2) {
      final result = await _pertumbuhanService.getAllPertumbuhanByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 3) {
      final result = await _pertumbuhanService.getAllPertumbuhanByUId(
        profile.id,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _pertumbuhanService.getAllPertumbuhan();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createPertumbuhan(PertumbuhanModel pertumbuhan) async {
    state = const AsyncValue.loading();
    try {
      final result = await _pertumbuhanService.createPertumbuhan(pertumbuhan);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Pertumbuhan: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchPertumbuhanById(String id) async {
    state = const AsyncValue.loading();
    final result = await _pertumbuhanService.getPertumbuhanById(id);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updatePertumbuhan(PertumbuhanModel updated) async {
    state = const AsyncValue.loading();
    try {
      final result = await _pertumbuhanService.updatePertumbuhan(updated);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((p) {
          return p.id == updated.id ? updated : p;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deletePertumbuhan(PertumbuhanModel pertumbuhan) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      final result = await _pertumbuhanService.deletePertumbuhan(
        pertumbuhan.id,
      );
      if (!ref.mounted) return;
      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((p) => p.id != pertumbuhan.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
