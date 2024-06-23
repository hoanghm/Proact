import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "PROACT",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 54,
              fontWeight: FontWeight.w400,
              shadows: [
                const Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color.fromRGBO(0, 0, 0, 0.25)
                )
              ]
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          ),
          ElevatedButton(
            onPressed: () => {}, 
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                backgroundColor: const Color.fromRGBO(6, 40, 6, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
                )
              ),
            child: Text(
              textAlign: TextAlign.center,
              "Begin my journey",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w400
              ),
            ) 
          )
        ],
      )
    );
  }
}