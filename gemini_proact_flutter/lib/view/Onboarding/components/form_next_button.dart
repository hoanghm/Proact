import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormNextButton extends StatelessWidget {
  final void Function() onCallback;
  final Color buttonColor = const Color.fromRGBO(89, 155, 67, 1);
  const FormNextButton({super.key, required this.onCallback});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {
          onCallback();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
        ),
        child: Text(
          "Submit",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            color: Colors.white
          ),
        )
      ),
    );
  }
}