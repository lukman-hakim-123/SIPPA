import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/build_context_extension.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state.value != null) {
        context.go('/home');
      } else if (state.hasError) {
        final errorMessage = state.error is String
            ? state.error as String
            : state.error.toString();

        context.showSnackBar('Login Gagal: $errorMessage', Status.error);
      }
    });

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: 'Masuk',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: AssetImage(
                              'assets/icons/sippa.png',
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: CustomText(
                              text:
                                  'Sistem Informasi Pertumbuhan dan Perkembangan Anak',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          ValidationHelper.validateEmail(value),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      maxLines: 1,
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (value) =>
                          ValidationHelper.validateMultiple(value, [
                            (v) => ValidationHelper.validateNotEmpty(
                              v,
                              'Password',
                            ),
                            (v) => ValidationHelper.validateMinLength(
                              v,
                              8,
                              'Password',
                            ),
                          ]),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: 'MASUK',
                      isLoading: authState.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          ref
                              .read(authProvider.notifier)
                              .login(
                                _emailController.text,
                                _passwordController.text,
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
