import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Gotoz whole app theme
class Themes {
  ThemeData lightTheme(BuildContext context) {
    return ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.transparent),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(
                color: Color.fromRGBO(0, 0, 0, 1), size: 26),
            titleTextStyle: GoogleFonts.manrope(
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 20),
            )),
        textTheme: GoogleFonts.manropeTextTheme(
            Theme.of(context).textTheme.apply(bodyColor: Colors.black)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            backgroundColor: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.transparent));
  }
}
