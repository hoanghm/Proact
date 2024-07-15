import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCardLabel extends StatefulWidget {
  final String label;
  const HomeCardLabel({super.key, required this.label});
  @override
  HomeCardLabelState createState() {
    return HomeCardLabelState();
  }
}

class HomeCardLabelState extends State<HomeCardLabel> {
  @override
  Widget build (BuildContext context) {
    return Container(
      width: 135,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        widget.label,
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 22
        ),
      )
    );
  }
}