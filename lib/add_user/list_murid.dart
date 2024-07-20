import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/add_user/controller/user_controller.dart';
import 'package:sippa/constant/appwrite.dart';
import 'package:sippa/models/user.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';

class MuridListPage extends ConsumerStatefulWidget {
  static route({required kelompok}) => MaterialPageRoute(
      builder: (context) => MuridListPage(kelompok: kelompok));

  final String kelompok;
  const MuridListPage({super.key, required this.kelompok});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MuridListPageState();
}

class _MuridListPageState extends ConsumerState<MuridListPage> {
  int selectedIndex = 2;
  List<User> muridList = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    final initialList =
        await ref.read(getMuridByFiltersProvider(widget.kelompok).future);
    if (mounted) {
      setState(() => muridList = initialList);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RealtimeMessage>>(getLatestUsersProvider, (_, next) {
      next.whenData((data) {
        if (data.events.contains(
          'databases.*.collections.${AppwriteConstants.collectionUserId}.documents.*.create',
        )) {
          final newUser = User.fromMap(data.payload);
          if (newUser.kelompok == widget.kelompok &&
              !muridList.any((existingUser) => existingUser.id == newUser.id)) {
            setState(() => muridList.add(newUser));
          }
        }
      });
    });

    return Scaffold(
      appBar: const CustomAppBar(title: 'Daftar Murid'),
      body: muridList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: muridList.length,
              itemBuilder: (context, index) {
                final murid = muridList[index];
                return ListTile(
                  title: Text(murid.nama),
                  subtitle: Text('Kelompok: ${murid.kelompok}'),
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
