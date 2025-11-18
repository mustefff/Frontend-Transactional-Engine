import 'package:flutter/material.dart';

import 'package:frontend_transactional_engine/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/login_pin_screen.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/login_screen.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/register_screen.dart';
import 'package:frontend_transactional_engine/features/auth/presentation/pages/set_pin_screen.dart';
import 'package:frontend_transactional_engine/features/dashboard/presentation/pages/wallet_overview_screen.dart';

class AppRouter {
  static const register = '/register';
  static const otp = '/otp';
  static const completeProfile = '/complete-profile';
  static const setPin = '/set-pin';
  static const login = '/login';
  static const loginPin = '/login-pin';
  static const dashboard = '/dashboard';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otp:
        final args = settings.arguments;
        String? phoneNumber;
        OtpFlowType flowType = OtpFlowType.registration;

        if (args is OtpVerificationArgs) {
          phoneNumber = args.phoneNumber;
          flowType = args.flowType;
        } else if (args is String) {
          phoneNumber = args;
        }

        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: phoneNumber ?? '',
            flowType: flowType,
          ),
        );
      case completeProfile:
        return MaterialPageRoute(
          builder: (_) => const CompleteProfileScreen(),
        );
      case setPin:
        return MaterialPageRoute(
          builder: (_) => const SetPinScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case loginPin:
        return MaterialPageRoute(
          builder: (_) => const LoginPinScreen(),
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const WalletOverviewScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
    }
  }
}

