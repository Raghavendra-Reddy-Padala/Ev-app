import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextTheme {
  static double _sizeFactor(double scale) => scale.sp;

  static final TextStyle bodySmallXP = GoogleFonts.poppins(
    fontSize: _sizeFactor(10),
    fontWeight: FontWeight.normal,
  );
  static final TextStyle bodySmallXPBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(10),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodySmallP = GoogleFonts.poppins(
    fontSize: _sizeFactor(14),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodySmallPBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(14),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyMediumP = GoogleFonts.poppins(
    fontSize: _sizeFactor(16),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyMediumPBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(16),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyLargeP = GoogleFonts.poppins(
    fontSize: _sizeFactor(18),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyLargePBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(18),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineSmallP = GoogleFonts.poppins(
    fontSize: _sizeFactor(20),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle headlineSmallPBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(20),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineMediumP = GoogleFonts.poppins(
    fontSize: _sizeFactor(22),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle headlineMediumPBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(22),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineLargeP = GoogleFonts.poppins(
    fontSize: _sizeFactor(24),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle headlineLargePBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(24),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineXLargeP = GoogleFonts.poppins(
    fontSize: _sizeFactor(26),
    fontWeight: FontWeight.normal,
  );

  static final TextStyle headlineXLargePBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(26),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineXXLargePBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(35),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headlineXXXLargePBold = GoogleFonts.poppins(
    fontSize: _sizeFactor(45),
    fontWeight: FontWeight.w600,
  );

  static final TextStyle transactionText = GoogleFonts.poppins(
    fontSize: _sizeFactor(16),
    fontWeight: FontWeight.w400,
    color: Colors.red,
  );
}
