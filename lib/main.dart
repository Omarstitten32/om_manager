import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/file_manager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.manageExternalStorage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OM Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().useMaterial3,
      home: const FileManagerScreen(),
    );
  }
}
