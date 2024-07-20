import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sippa/widget_view/appbar.dart';
import 'package:sippa/widget_view/drawer.dart';
import 'package:sippa/widget_view/teks.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class AnekdotPage extends ConsumerStatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AnekdotPage());

  const AnekdotPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnekdotPageState();
}

class _AnekdotPageState extends ConsumerState<AnekdotPage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      appBar: const CustomAppBar(
        title: 'Anekdot',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            const SizedBox(
              height: 16,
            ),
            const CustomText(
              text: "Catatan Anekdot 2022/2023",
              fontSize: 20,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.end,
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3)),
                  child: const CustomText(
                    text: "Tambah Data",
                    color: Colors.white,
                  )),
            ),
            const SizedBox(
              height: 16,
            ),
            Table(
              border: TableBorder.all(color: Colors.black, width: 1),
              children: [
                TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomText(
                          text: 'Nama: Lukman',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomText(text: 'Bulan: Juli 2022'),
                      ),
                    ]),
                const TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomText(text: 'Kelompok: B (5-6 Tahun)'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomText(text: 'Guru Kelas: Umi N'),
                  ),
                ])
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Table(
              border: TableBorder.all(color: Colors.black, width: 1),
              children: [
                TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomText(
                          text: 'Tanggal: Ruang sentra, 13 Sept 2022',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CustomText(text: 'Analaisis Capaian'),
                      ),
                    ]),
                const TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomText(
                      text: '''Tanggal: Ruang sentra, 13 Se
                          
                          ptasjhgbdagfbg gfeobaugbiusgfoiwvf f
                          hvbikgvylrclurcgbvocgfoiqwfbvc qfbg “Ini nasi dan ikan buat nda”, kata Kio sambil menyodor- kan kepadaku sepiring lego. Sebentar nda Kio mau bikin kereta panjang, kemudian ia berlari menuju legonya 2022''',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomText(text: 'Analaisis Capaian'),
                  ),
                ]),
              ],
            )
          ],
        ),
      ),
    );
  }
}
