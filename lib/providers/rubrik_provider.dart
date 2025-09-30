import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/rubrik.dart';
import '../services/rubrik_service.dart';
import '../utils/provider.dart';
import 'user_provider.dart';

part 'rubrik_provider.g.dart';

@riverpod
class RubrikNotifier extends _$RubrikNotifier {
  late final RubrikService _rubrikService = RubrikService(
    db: ref.read(appwriteTableDBProvider),
  );

  @override
  Future<List<RubrikModel>> build() async {
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
      final result = await _rubrikService.getAllRubrikBySekolah(
        profile.sekolah,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 2) {
      final result = await _rubrikService.getAllRubrikByKelompok(
        profile.sekolah,
        profile.kelompok,
      );
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 3) {
      final result = await _rubrikService.getAllRubrikByUId(
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
      final result = await _rubrikService.getAllRubrik();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createRubrik(RubrikModel rubrik) async {
    state = const AsyncValue.loading();
    try {
      final result = await _rubrikService.createRubrik(rubrik);

      if (result.isSuccess) {
        state = AsyncValue.data([result.resultValue!, ...state.value ?? []]);
      } else {
        throw Exception("Gagal menyimpan Rubrik: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchRubrikById(String rubrikId) async {
    state = const AsyncValue.loading();
    final result = await _rubrikService.getRubrikById(rubrikId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateRubrik(RubrikModel updatedRubrik) async {
    state = const AsyncValue.loading();
    try {
      final result = await _rubrikService.updateRubrik(updatedRubrik);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((rubrik) {
          return rubrik.id == updatedRubrik.id ? updatedRubrik : rubrik;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteRubrik(RubrikModel rubrik) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      final result = await _rubrikService.deleteRubrik(rubrik.id);
      if (!ref.mounted) return;
      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((g) => g.id != rubrik.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
