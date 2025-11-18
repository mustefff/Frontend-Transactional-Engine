import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend_transactional_engine/core/routing/app_router.dart';
import 'package:frontend_transactional_engine/features/auth/application/auth_flow_controller.dart';
import 'package:frontend_transactional_engine/features/auth/data/real_auth_service.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend_transactional_engine/features/dashboard/presentation/pages/wallet_overview_screen.dart';
import 'package:frontend_transactional_engine/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RealAuthService>(
          create: (_) => RealAuthService(),
        ),
        ChangeNotifierProvider<AuthFlowController>(
          create: (context) => AuthFlowController(
            realAuthService: context.read<RealAuthService>(),
          ),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = AppRouter.register; // Initialiser avec une valeur par défaut
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Vérifier si l'utilisateur a déjà un token (est authentifié)
    final token = await ApiService.getToken();
    
    setState(() {
      // Si un token existe, rediriger vers le dashboard
      // Sinon, rediriger vers l'écran d'inscription
      _initialRoute = token != null && token.isNotEmpty 
          ? AppRouter.dashboard 
          : AppRouter.register;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Afficher un écran de chargement pendant la vérification
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final router = AppRouter();
    
    // Utiliser 'home' au lieu de 'initialRoute' pour éviter les problèmes de null
    Widget initialWidget;
    if (_initialRoute == AppRouter.dashboard) {
      initialWidget = const WalletOverviewScreen();
    } else {
      initialWidget = const RegisterScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frontend Transactional Engine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: initialWidget,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
