import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/app/api/user_api.dart';
import 'package:dio/dio.dart';
import 'package:template/app/models/apply_model.dart';
import 'package:template/app/models/user_model.dart';
import 'package:template/app/api/dio_client.dart';
import 'package:go_router/go_router.dart';
import 'package:template/app/routing/router_service.dart';
import 'package:template/app/theme/colors.dart';

class ReceivedApplicationsPage extends StatefulWidget {
  const ReceivedApplicationsPage({super.key});

  @override
  State<ReceivedApplicationsPage> createState() =>
      _ReceivedApplicationsPageState();
}

class _ReceivedApplicationsPageState extends State<ReceivedApplicationsPage> {
  List<ApplyModel>? _applications;
  bool isPatient = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplications());
  }

  Future<void> _loadApplications() async {
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (idToken == null) throw Exception('No ID Token');

      final userApi = UserApi(MyDio(dio: Dio()));
      userApi.setAuthToken(idToken);

      final userResult = await userApi.getUser();
      final user = userResult.data;

      isPatient = user.role;

      final applies = isPatient
          ? await userApi.getReceivedApplications(idToken)
          : await userApi.getAppliedPatients(idToken);

      setState(() {
        _applications = applies;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Fail to load: $e");
      setState(() {
        _applications = [];
        isLoading = false;
      });
    }
  }

  Future<void> _accept(String uId) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    if (idToken == null) return;

    final birthday = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Recorder Birthday'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'input format: YYYY-MM-DD ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('delete'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('check'),
            ),
          ],
        );
      },
    );

    if (birthday == null || birthday.isEmpty) return;

    try {
      final userApi = UserApi(MyDio(dio: Dio()));
      await userApi.acceptApplication(
        userId: uId,
        birthday: birthday.trim(),
        idToken: idToken,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Application accepted")));
      _loadApplications();
    } catch (e) {
      debugPrint("❌ Accept Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("❌ Application Failed - Check the birthday")),
      );
    }
  }

  Future<void> _reject(String uId) async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) return;

    try {
      final userApi = UserApi(MyDio(dio: Dio()));
      await userApi.rejectApplication(userId: uId, idToken: idToken);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Rejected")));
      _loadApplications();
    } catch (e) {
      debugPrint("❌ 거절 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(Routes.home);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_applications == null || _applications!.isEmpty)
              ? const Center(child: Text('No Applications.'))
              : ListView.builder(
                  itemCount: _applications!.length,
                  itemBuilder: (context, index) {
                    final apply = _applications![index];
                    return Card(
                      child: ListTile(
                        title: Text(apply.uName),
                        trailing: isPatient
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _accept(apply.uId),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _reject(apply.uId),
                                  ),
                                ],
                              )
                            : const Text('Applying',
                                style: TextStyle(color: AppColors.secondary)),
                      ),
                    );
                  },
                ),
      floatingActionButton: isPatient
          ? null
          : FloatingActionButton(
              onPressed: () {
                context.go(Routes.recorderRegister);
              },
              tooltip: 'Add Application',
              child: const Icon(Icons.add),
            ),
    );
  }
}
