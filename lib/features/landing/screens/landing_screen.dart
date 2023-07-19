import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp_ui/colors.dart';
import 'package:whatsapp_ui/features/auth/screens/login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  void navigateToLoginScreen(BuildContext ctx) {
    Navigator.pushNamed(ctx, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  Image.asset(
                    'assets/landing_page.jpg',
                    width: size.width * 1,
                    // color: Colors.blue,
                  ),
                  Image.asset(
                    'assets/logo.png', height: 40, width: 90,

                    // color: Colors.blue,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Share photos and',
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                              color: blactextColor,
                              fontSize: 29,
                              fontWeight: FontWeight.w800),
                        )),
                    Row(
                      children: [
                        Text('videos,',
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  color: blactextColor,
                                  fontSize: 29,
                                  fontWeight: FontWeight.w800),
                            )),
                        Text('Stay connected',
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  color: Color.fromRGBO(237, 84, 60, 1),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800),
                            )),
                      ],
                    ),
                    Text('wherever you go',
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                              color: blactextColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          'Read our',
                          style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(5, 31, 50, 0.6))),
                        ),
                        Text(
                          ' privacy policy. ',
                          style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(58, 97, 234, 1))),
                        ),
                        Text(
                          'By clicking continue',
                          style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(5, 31, 50, 0.6))),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'you are agreeing to our',
                          style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(5, 31, 50, 0.6))),
                        ),
                        Text(
                          ' terms of service.',
                          style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(58, 97, 234, 1))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45),
                    InkWell(
                      onTap: () => navigateToLoginScreen(context),
                      child: Container(
                        height: 54,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(41),
                            color: const Color.fromRGBO(237, 84, 60, 1)),
                        child: Center(
                          child: Text('Get Started',
                              style: GoogleFonts.manrope(
                                textStyle: const TextStyle(
                                    color: whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // SizedBox(
              //   width: size.width * 0.75,
              //   child: CustomButton(
              //     text: 'Get Started',
              //     onPressed: () => navigateToLoginScreen(context),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
