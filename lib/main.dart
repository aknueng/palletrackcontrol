import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:palletrackcontrol/pages/login.dart';
import 'package:palletrackcontrol/pages/scanpalletrack.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkAccount();
  runApp(const MyApp());
}

String initPage = '/scan';
Future checkAccount() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String chkLogin = prefs.getString('code') ?? '';
  if (chkLogin == '' || chkLogin.isEmpty) {
    initPage = '/login';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pallet Control',
      debugShowCheckedModeBanner: false,
      initialRoute: initPage,
      getPages: [
        GetPage(
            name: '/login',
            page: () => const LoginPage(),
            transition: Transition.cupertino),
        GetPage(
            name: '/scan',
            page: () => const ScanRackPage(),
            transition: Transition.cupertino),
        GetPage(
            name: '/regis',
            page: () => const ScanRackPage(),
            transition: Transition.cupertino),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
