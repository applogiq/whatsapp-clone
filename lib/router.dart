import 'package:flutter/material.dart';

import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_ui/features/auth/screens/user_informayion_screen.dart';
import 'package:whatsapp_ui/features/group/screens/create_group_screen.dart';
import 'package:whatsapp_ui/features/select_contact/screens/select_contacts_screens.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case OTPScreen.routeName:
      final verificationId = settings.arguments as String;
      final phoneNumber = settings.arguments as String;
      // final isLoad = settings.arguments as bool;

      return MaterialPageRoute(
          builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              ));
    case UserInformationScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const UserInformationScreen());
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
          builder: (context) => const SelectContactsScreen());

    case CreateGroupScreen.routeName:
      return MaterialPageRoute(builder: (context) => const CreateGroupScreen());
    default:
      return MaterialPageRoute(
          builder: (context) => const Scaffold(
                body: ErrorSccreen(
                  error: "This page is does;nt exsist",
                ),
              ));
  }
}
