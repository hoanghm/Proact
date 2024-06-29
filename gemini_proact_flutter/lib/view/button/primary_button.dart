import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:gemini_proact_flutter/view/icon/square_tile.dart';

/// Button with primary style.
class PrimaryButton extends StatelessWidget {
  final String? imagePath;
  final String? text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key, 
    this.imagePath, 
    this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          // TODO use ColorPalette for background color
          backgroundColor: const Color.fromRGBO(89, 155, 67, 1),
          // TODO use ColorPalette for foreground color
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(15),
        ), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) SquareTile(imagePath: imagePath!, size: 20,),
            if (imagePath != null && text != null) const SizedBox(width: 10,),
            if (text != null) Text(
              text!,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w400,                  
              ),
            )
          ],
        )
      ),
    );
  }
}