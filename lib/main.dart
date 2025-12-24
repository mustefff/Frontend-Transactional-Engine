import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend_transactional_engine/core/routing/app_router.dart';
import 'package:frontend_transactional_engine/features/auth/application/auth_flow_controller.dart';
import 'package:frontend_transactional_engine/features/auth/domain/auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/data/real_auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/data/mock_auth_service.dart';
import 'package:frontend_transactional_engine/features/wallet/data/wallet_service.dart';
import 'package:frontend_transactional_engine/features/wallet/application/wallet_controller.dart';

void main() {
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Utiliser le service réel pour communiquer avec le backend
        Provider<AuthService>(
          create: (_) => RealAuthService(
            // 10.0.2.2 est l'adresse spéciale pour l'émulateur Android
            // qui pointe vers localhost de la machine hôte
            baseUrl: 'http://10.0.2.2:8080',
            keycloakUrl: 'http://10.0.2.2:9080',
          ),
          // Pour utiliser le mock à la place, décommentez ci-dessous:
          // create: (_) => MockAuthService(),
        ),
        ChangeNotifierProvider<AuthFlowController>(
          create: (context) => AuthFlowController(
            authService: context.read<AuthService>(),
          ),
        ),
        // Service Wallet pour gérer les comptes et transferts
        Provider<WalletService>(
          create: (_) => WalletService(
            baseUrl: 'http://10.0.2.2:8080',
          ),
        ),
        ChangeNotifierProvider<WalletController>(
          create: (context) => WalletController(
            walletService: context.read<WalletService>(),
          ),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frontend Transactional Engine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRouter.register,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
