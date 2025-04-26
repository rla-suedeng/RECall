import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/theme/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:template/app/auth/firebase_auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('RECall',
                  style: GoogleFonts.pacifico(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary)),
              const SizedBox(height: 8),
              const Text('Welcome Back', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              const Text('Sign in to rediscover your memories'),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
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
                    icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => isObscure = !isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password flow
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final authService = GetIt.I<FirebaseAuthService>();
                    try {
                      final user = await authService.signInWithEmail(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                      if (user != null) {
                        debugPrint('✅ 로그인 성공: ${user.email}');
                        context.go(Routes.home);
                      }
                    } catch (e) {
                      debugPrint('❌ 로그인 실패: $e');
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Login Failed'),
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
                  child: const Text('Sign In'),
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
                  onPressed: () async {
                    debugPrint('✅ 구글 로그인 버튼 눌림');
                    if (mounted) {
                      context.go(Routes.home); // ✅ Google도 그냥 HomePage 이동
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.go(Routes.register);
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    children: [
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
