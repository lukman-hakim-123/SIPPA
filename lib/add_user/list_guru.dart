import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';

class GuruListPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const GuruListPage());
  const GuruListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GuruListPageState();
}

class _GuruListPageState extends ConsumerState<GuruListPage> {
  int selectedIndex = 2;
  List<User> guruList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(getGuruByFiltersProvider.future)
        .then((value) => setState(() => guruList = value)));
  }

  @override
  Widget build(BuildContext context) {
    // final guruAsyncValue = ref.watch(getGuruByFiltersProvider);
    // ref.watch(combinedGuruListProvider);
    ref.listen<AsyncValue<RealtimeMessage>>(getLatestUsersProvider, (_, next) {
      next.whenData((data) {
        if (data.events.contains(
            'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create')) {
          final newUser = User.fromMap(data.payload);
          if (!guruList.any((existingUser) => existingUser.id == newUser.id)) {
            setState(() => guruList.add(newUser));
          }
        }
      });
    });
    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Guru'),
      body: ListView.builder(
        itemCount: guruList.length,
        itemBuilder: (context, index) {
          final guru = guruList[index];
          return ListTile(
            title: Text(guru.nama),
            subtitle: Text('Kelompok: ${guru.kelompok}'),
          );
        },
      ),
      drawer: CustomDrawer(
        selectedIndex: selectedIndex,
        onItemSelected: (int index) {
          selectedIndex = index;
        },
      ),
    );
  }
}
