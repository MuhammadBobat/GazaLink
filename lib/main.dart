import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/bluetooth_service.dart';
import 'services/storage_service.dart';
import 'screens/message_queue_screen.dart';
import 'screens/message_create_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const GazaLinkApp());
}

class GazaLinkApp extends StatelessWidget {
  const GazaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BluetoothService>(
          create: (_) => BluetoothService(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
      ],
      child: MaterialApp.router(
        title: 'GazaLink',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C3E50),
            brightness: Brightness.light,
          ),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MessageQueueScreen(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const MessageCreateScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
