import 'package:go_router/go_router.dart';
import 'package:sippa/screens/anekdot/anekdot_screen.dart';
import '../models/user.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/admin/detail_admin_screen.dart';
import '../screens/admin/form_admin_screen.dart';
import '../screens/anekdot/detail_anekdot_screen.dart';
import '../screens/anekdot/form_anekdot_screen.dart';
import '../screens/anekdot/pilih_murid_anekdot_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/capaian_pembelajaran/cp_screen.dart';
import '../screens/capaian_pembelajaran/detail_cp_screen.dart';
import '../screens/capaian_pembelajaran/form_cp_screen.dart';
import '../screens/capaian_pembelajaran/pilih_murid_cp_screen.dart';
import '../screens/guru/detail_guru_screen.dart';
import '../screens/guru/form_guru_screen.dart';
import '../screens/guru/guru_screen.dart';
import '../screens/hasil_karya/detail_hk_screen.dart';
import '../screens/hasil_karya/form_hk_screen.dart';
import '../screens/hasil_karya/hk_screen.dart';
import '../screens/hasil_karya/pilih_murid_hk_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/pertumbuhan/detail_pertumbuhan_screen.dart';
import '../screens/pertumbuhan/form_pertumbuhan_screen.dart';
import '../screens/pertumbuhan/pertumbuhan_screen.dart';
import '../screens/pertumbuhan/pilih_murid_pertumbuhan_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/murid/detail_murid_screen.dart';
import '../screens/murid/form_murid_screen.dart';
import '../screens/murid/murid_screen.dart';
import '../screens/report/pilih_murid_report_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/rubrik/detail_rubrik_screen.dart';
import '../screens/rubrik/form_rubrik_screen.dart';
import '../screens/rubrik/pilih_murid_rubrik_screen.dart';
import '../screens/rubrik/rubrik_screen.dart';
import 'arg/anekdot_arg.dart';
import 'arg/cp_arg.dart';
import 'arg/hk_arg.dart';
import 'arg/pertumbuhan_arg.dart';
import 'arg/report_arg.dart';
import 'arg/rubrik_arg.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    GoRoute(path: '/murid', builder: (context, state) => MuridScreen()),
    GoRoute(
      path: '/formMurid',
      builder: (context, state) {
        final murid = state.extra as User?;
        return FormMuridScreen(murid: murid);
      },
    ),
    GoRoute(
      path: '/detailMurid',
      builder: (context, state) {
        final murid = state.extra as User;
        return DetailMuridScreen(murid: murid);
      },
    ),
    GoRoute(path: '/guru', builder: (context, state) => GuruScreen()),
    GoRoute(
      path: '/formGuru',
      builder: (context, state) {
        final guru = state.extra as User?;
        return FormGuruScreen(guru: guru);
      },
    ),
    GoRoute(
      path: '/detailGuru',
      builder: (context, state) {
        final guru = state.extra as User;
        return DetailGuruScreen(guru: guru);
      },
    ),
    GoRoute(path: '/admin', builder: (context, state) => AdminScreen()),
    GoRoute(
      path: '/formAdmin',
      builder: (context, state) {
        final admin = state.extra as User?;
        return FormAdminScreen(admin: admin);
      },
    ),
    GoRoute(
      path: '/detailAdmin',
      builder: (context, state) {
        final admin = state.extra as User;
        return DetailAdminScreen(admin: admin);
      },
    ),
    GoRoute(path: '/anekdot', builder: (context, state) => AnekdotScreen()),
    GoRoute(
      path: '/pilihAnakAnekdot',
      builder: (context, state) => PilihMuridAnekdotScreen(),
    ),
    GoRoute(
      path: '/formAnekdot',
      builder: (context, state) {
        final args = state.extra as AnekdotArgs;
        return FormAnekdotScreen(anekdot: args.anekdot, murid: args.murid);
      },
    ),
    GoRoute(
      path: '/detailAnekdot',
      builder: (context, state) {
        final id = state.extra as String;
        return DetailAnekdotScreen(anekdotId: id);
      },
    ),
    GoRoute(path: '/cp', builder: (context, state) => CpScreen()),
    GoRoute(
      path: '/pilihAnakCp',
      builder: (context, state) => PilihMuridCpScreen(),
    ),
    GoRoute(
      path: '/formCp',
      builder: (context, state) {
        final args = state.extra as CpArgs;
        return FormCpScreen(cp: args.cp, murid: args.murid);
      },
    ),
    GoRoute(
      path: '/detailCp',
      builder: (context, state) {
        final id = state.extra as String;
        return DetailCpScreen(cpId: id);
      },
    ),
    GoRoute(path: '/hk', builder: (context, state) => HkScreen()),
    GoRoute(
      path: '/pilihAnakHk',
      builder: (context, state) => PilihMuridHkScreen(),
    ),
    GoRoute(
      path: '/formHk',
      builder: (context, state) {
        final args = state.extra as HkArgs;
        return FormHkScreen(hk: args.hk, murid: args.murid);
      },
    ),
    GoRoute(
      path: '/detailHk',
      builder: (context, state) {
        final id = state.extra as String;
        return DetailHkScreen(hkId: id);
      },
    ),
    GoRoute(
      path: '/pertumbuhan',
      builder: (context, state) => PertumbuhanScreen(),
    ),
    GoRoute(
      path: '/pilihAnakPertumbuhan',
      builder: (context, state) => PilihMuridPertumbuhanScreen(),
    ),
    GoRoute(
      path: '/formPertumbuhan',
      builder: (context, state) {
        final args = state.extra as PertumbuhanArgs;
        return FormPertumbuhanScreen(
          pertumbuhan: args.pertumbuhan,
          murid: args.murid,
        );
      },
    ),
    GoRoute(
      path: '/detailPertumbuhan',
      builder: (context, state) {
        final id = state.extra as String;
        return DetailPertumbuhanScreen(pertumbuhanId: id);
      },
    ),
    GoRoute(path: '/rubrik', builder: (context, state) => RubrikScreen()),
    GoRoute(
      path: '/pilihAnakRubrik',
      builder: (context, state) => PilihMuridRubrikScreen(),
    ),
    GoRoute(
      path: '/formRubrik',
      builder: (context, state) {
        final args = state.extra as RubrikArgs;
        return FormRubrikScreen(rubrik: args.rubrik, murid: args.murid);
      },
    ),
    GoRoute(
      path: '/detailRubrik',
      builder: (context, state) {
        final id = state.extra as String;
        return DetailRubrikScreen(rubrikId: id);
      },
    ),
    GoRoute(
      path: '/pilihMuridReport',
      builder: (context, state) => PilihMuridReportScreen(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) {
        final args = state.extra as ReportArgs;
        return ReportScreen(
          anakId: args.anakId,
          nama: args.nama,
          sekolah: args.sekolah,
          kelompok: args.kelompok,
        );
      },
    ),
  ],
);
