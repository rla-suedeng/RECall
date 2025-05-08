import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/api/user_api.dart';
import 'package:template/app/theme/colors.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:template/app/auth/firebase_auth_service.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isObscure = true;
  bool isConfirmObscure = true;
  String? _selectedRole; // 'Reminder' or 'Recorder'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
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
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
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
                                DateFormat('yyyy-MM-dd').format(picked);
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

                      // --- Role Select ---
                      const SizedBox(height: 16),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Role',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          RadioListTile<String>(
                            title: const Text('Reminder'),
                            value: 'reminder',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Recorder'),
                            value: 'recorder',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value;
                              });
                            },
                          ),
                        ],
                      ),

                      // --- Create Account Button ---
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            final confirmPassword =
                                confirmPasswordController.text.trim();

                            if (password != confirmPassword) {
                              showDialog(
                                context: context,
                                builder: (context) => const AlertDialog(
                                  title: Text('Passwords do not match'),
                                  content: Text('Please check your password.'),
                                ),
                              );
                              return;
                            }
                            final authService = GetIt.I<FirebaseAuthService>();
                            final userApi = GetIt.I<UserApi>();

                            try {
                              // firebase register
                              final user = await authService.signUpWithEmail(
                                  email, password);
                              if (user != null) {
                                debugPrint(
                                    '✅ Firebase Register Clear: ${user.uid}');
                                final token = await user.getIdToken();
                                if (token == null)
                                  throw Exception("No firebase token");

                                userApi.setAuthToken(token);
                                // save to FastAPI DB
                                final result = await userApi.register(
                                  uId: user.uid,
                                  password: password, //해시 처리
                                  role: _selectedRole ==
                                      "reminder", //reminder = 1
                                  fName: firstNameController.text.trim(),
                                  lName: lastNameController.text.trim(),
                                  birthday: birthDateController.text.trim(),
                                  email: email,
                                  pId: null, //추후 연결
                                );
                                if (result.isSuccess) {
                                  debugPrint('✅ DB 등록 성공: ${result.data}');

                                  // 역할에 따라 페이지 이동
                                  if (_selectedRole == 'recorder') {
                                    context.go(Routes.recorderRegister);
                                  } else {
                                    context.go(Routes.login);
                                  }
                                } else {
                                  final error = result.error;
                                  debugPrint('❌ DB 등록 실패: ${error.message}');
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Register Failed'),
                                      content: Text(
                                          'Failed to save user info: ${error.message}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('❌ Regiset Fail: $e');
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
