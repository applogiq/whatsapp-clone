// ignore_for_file: unused_local_variable

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/theme.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/interner_connectivity/controller/internet_connection_controller.dart';
import 'package:whatsapp_ui/features/interner_connectivity/screen/no_internet_screen.dart';
import 'package:whatsapp_ui/features/landing/screens/landing_screen.dart';
import 'package:whatsapp_ui/firebase_options.dart';
import 'package:whatsapp_ui/router.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  getDeviceToken();

  runApp(const ProviderScope(child: MyApp()));
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

void getDeviceToken() async {
  String? token = await _firebaseMessaging.getToken();
}

void setupFirebaseMessaging() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    final internetConnectionStatus =
        ref.watch(internetConnectionStatusProvider);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Whatsapp UI',
        theme: Themes().lightTheme(context),
        onGenerateRoute: (settings) => generateRoute(settings),
        home: internetConnectionStatus ==
                const AsyncValue.data(InternetConnectionStatus.disconnected)
            ? const NoInternetScreen()
            : ref.watch(userdataProvider).when(
                data: (user) {
                  if (user == null) {
                    return const LandingScreen();
                  } else {
                    return const MobileLayoutScreen();
                  }
                },
                error: (error, trace) {
                  return ErrorSccreen(error: error.toString());
                },
                loading: () => const Scaffold(body: Loader())));
  }
}
