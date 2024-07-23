import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionStepTab extends StatefulWidget {
  final String stepDescription;
  const MissionStepTab({super.key, required this.stepDescription});
  
  @override
  MissionStepTabState createState() {
    return MissionStepTabState();
  }
}

class MissionStepTabState extends State<MissionStepTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 25,
            height: 25,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Colors.black
            ),
          ),
          Flexible(
            child: Text(
              widget.stepDescription,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16
              ),
            )
          )
        ],
      ),
    );
  }
}