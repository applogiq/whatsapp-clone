import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/common/widgets/error.dart';
import 'package:whatsapp_ui/common/widgets/loader.dart';
import 'package:whatsapp_ui/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_ui/features/landing/screens/landing_screen.dart';
import 'package:whatsapp_ui/firebase_options.dart';
import 'package:whatsapp_ui/router.dart';
import 'package:whatsapp_ui/screens/mobile_layout_screen.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

Future<void> disableScreenRecordingAndScreenshots() async {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  disableScreenRecordingAndScreenshots();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Whatsapp UI',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: backgroundColor,
        ),
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
            loading: () => const Loader())
        //  const ResponsiveLayout(
        //   mobileScreenLayout: MobileLayoutScreen(),
        //   webScreenLayout: WebLayoutScreen(),
        // ),
        );
  }
}
