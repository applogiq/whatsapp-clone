import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/common/config/size_config.dart';
import 'package:whatsapp_ui/common/config/theme.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/landing/screens/landing_screen.dart';
import 'package:whatsapp_ui/firebase_options.dart';
import 'package:whatsapp_ui/router.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';

// Future<void> disableScreenRecordingAndScreenshots() async {
//   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // disableScreenRecordingAndScreenshots();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  getDeviceToken();
  // await setupFirebaseMessaging();

  runApp(const ProviderScope(child: MyApp()));
}

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

void getDeviceToken() async {
  String? token = await _firebaseMessaging.getToken();
  print('Device Token: $token');
// Send this token to your server for identification and future notification delivery
}

// void setupFirebaseMessaging() async {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print(
//         'Received message while app is in the foreground: ${message.notification}');
// // Handle the notification here
//   });
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('A new onMessageOpenedApp event was published!');
//   });
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// Handle the incoming message here
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Whatsapp UI',
        theme: Themes().lightTheme(context),
        onGenerateRoute: (settings) => generateRoute(settings),
        home: ref.watch(userdataProvider).when(
            data: (user) {
              if (user == null) {
                return const LandingScreen();
              } else {
                return const MobileLayoutScreen();
              }
            },
            error: (error, trace) {
              print(error.toString());
              return ErrorSccreen(error: error.toString());
            },
            loading: () => const Scaffold(body: Loader())));
  }
}
