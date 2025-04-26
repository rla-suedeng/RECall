import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:template/app/auth/firebase_auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isObscure = true;
  bool isConfirmObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ 키보드 올라올 때 화면 자동 줄이기
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // ✅ 최소 높이를 화면 높이에 맞춘다
                ),
                child: IntrinsicHeight(
                  // ✅ Column 높이를 자식에 맞추기
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text('RECall',
                          style: GoogleFonts.pacifico(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary)),
                      const SizedBox(height: 8),
                      const Text('Create Account',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Join us to start your journey'),
                      const SizedBox(height: 48),

                      // --- TextFields ---
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: birthDateController,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            birthDateController.text =
                                '${picked.year}-${picked.month}-${picked.day}';
                          }
                        },
                        decoration: const InputDecoration(
                          labelText: 'Birth date',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => isObscure = !isObscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: confirmPasswordController,
                        obscureText: isConfirmObscure,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(isConfirmObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => isConfirmObscure = !isConfirmObscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Create Account Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final authService = GetIt.I<FirebaseAuthService>();
                            try {
                              final user = await authService.signUpWithEmail(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                              if (user != null) {
                                debugPrint('✅ 회원가입 성공: ${user.email}');
                                context.go(Routes.login);
                              }
                            } catch (e) {
                              debugPrint('❌ 회원가입 실패: $e');
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Register Failed'),
                                  content: Text(e.toString()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    )
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text('Create Account'),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Row(children: <Widget>[
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('Or continue with'),
                        ),
                        Expanded(child: Divider()),
                      ]),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Sign in with Google'),
                          onPressed: () {
                            debugPrint('✅ Google Sign-In 눌림');
                          },
                        ),
                      ),
                      const Spacer(), // ✅ 남은 공간 채우기
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          TextButton(
                            onPressed: () {
                              context.go(Routes.login);
                            },
                            child: const Text('Sign in',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
