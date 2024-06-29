import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/root.dart' show Proact;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class ProactLogo extends Text {
  static final String logoText = Proact.appName.toUpperCase();

  final double size;

  ProactLogo({
    super.key,
    this.size = 54
  }) : super(
    logoText,
    style: GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w400,
      shadows: [
        const Shadow(
          offset: Offset(0, 4),
          blurRadius: 4,
          color: Color.fromRGBO(0, 0, 0, 0.25)
        )
      ]
    )
  );
}