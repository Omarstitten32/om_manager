import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/file_manager_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ready = await requestStorageAccess();
  runApp(MyApp(permissionsGranted: ready));
}

Future<bool> requestStorageAccess() async {
  if (!Platform.isAndroid) return true;

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final sdkInt = androidInfo.version.sdkInt;

  bool granted = true;

  if (sdkInt >= 30) {
    final manageStatus = await Permission.manageExternalStorage.status;
    if (!manageStatus.isGranted) {
      final manageResult = await Permission.manageExternalStorage.request();
      granted = manageResult.isGranted;
      if (!granted) {
        await openAppSettings();
        return false;
      }
    }
  } else {
    final storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      final storageResult = await Permission.storage.request();
      granted = storageResult.isGranted;
      if (!granted) {
        await openAppSettings();
        return false;
      }
    }
  }

  if (sdkInt >= 33) {
    final mediaPermissions = <Permission>[
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ];

    final mediaResults = await mediaPermissions.request();
    final mediaGranted = mediaResults.values.every((status) => status.isGranted);
    if (!mediaGranted) {
      granted = false;
      await openAppSettings();
      return false;
    }
  } else {
    final readStatus = await Permission.storage.status;
    if (!readStatus.isGranted) {
      final readResult = await Permission.storage.request();
      if (!readResult.isGranted) {
        await openAppSettings();
        return false;
      }
    }

    final writeStatus = await Permission.storage.status;
    if (!writeStatus.isGranted) {
      await Permission.storage.request();
    }
  }

  return granted;
}

class MyApp extends StatelessWidget {
  final bool permissionsGranted;

  const MyApp({super.key, required this.permissionsGranted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mt Manager',
      theme: ThemeData.dark(),
      home: permissionsGranted
          ? const FileManagerScreen()
          : const PermissionDeniedScreen(),
    );
  }
}

class PermissionDeniedScreen extends StatelessWidget {
  const PermissionDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: openAppSettings,
          child: const Text('Enable permissions'),
        ),
      ),
    );
  }
}