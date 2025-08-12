// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sippa/widget_view/appbar.dart';

// import '../auth/controllers/auth_controller.dart';

// class ForgotPassPage extends ConsumerStatefulWidget {
//   static route() =>
//       MaterialPageRoute(builder: (context) => const ForgotPassPage());
//   const ForgotPassPage({super.key});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPassPageState();
// }

// class _ForgotPassPageState extends ConsumerState<ForgotPassPage> {
//   final emailController = TextEditingController();
//   final newPasswordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   bool _isLoading = false;

//   @override
//   void dispose() {
//     emailController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _onChangePassword() async {
//     final email = emailController.text.trim();
//     final newPassword = newPasswordController.text;
//     final confirmPassword = confirmPasswordController.text;

//     if (email.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Semua field harus diisi')),
//       );
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Password dan konfirmasi password tidak sama')),
//       );
//       return;
//     }

//     if (newPassword.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password minimal 6 karakter')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Panggil method di auth controller untuk reset password langsung
//       await ref.read(authControllerProvider.notifier).(
//             email: email,
//             newPassword: newPassword,
//           );

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Password berhasil diubah')),
//       );

//       Navigator.pop(context); // Kembali ke halaman sebelumnya
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal mengubah password: $e')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(title: 'Reset Password'),
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 40),
//         child: Center(
//           child: Column(
//             children: [
//               const SizedBox(height: 60),
//               const Text(
//                 'Masukkan email dan password baru Anda untuk mengganti password.',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               TextField(
//                 keyboardType: TextInputType.emailAddress,
//                 controller: emailController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Email',
//                 ),
//               ),
//               const SizedBox(height: 22),
//               TextField(
//                 obscureText: true,
//                 controller: newPasswordController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Password Baru',
//                 ),
//               ),
//               const SizedBox(height: 22),
//               TextField(
//                 obscureText: true,
//                 controller: confirmPasswordController,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                   labelText: 'Konfirmasi Password Baru',
//                 ),
//               ),
//               const SizedBox(height: 22),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _onChangePassword,
//                 style: ButtonStyle(
//                   backgroundColor:
//                       MaterialStateProperty.all(const Color(0xff104993)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6.0),
//                     ),
//                   ),
//                   fixedSize:
//                       MaterialStateProperty.all(const Size.fromHeight(45)),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         "Ganti Password",
//                         style:
//                             TextStyle(fontFamily: 'inter', color: Colors.white),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
