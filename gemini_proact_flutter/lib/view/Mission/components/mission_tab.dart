import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionTab extends StatefulWidget {
  const MissionTab({super.key});

  @override
  MissionTabState createState() {
    return MissionTabState();
  }
}

class MissionTabState extends State<MissionTab> {
  @override
  Widget build (BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MissionPage()) 
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 15),
            backgroundColor: Colors.grey.shade300, 
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)
            )
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                    ),
                    child: Text(
                      "Mission 1",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                    ),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'CO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18
                            )
                          ),
                          TextSpan(
                            text: '2',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFeatures: [FontFeature.subscripts()]
                            )
                          ),
                          TextSpan(
                            text: ' High',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18
                            )
                          )
                        ]
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
                child: Text(
                  "Organize a 'Green Gig' event showcasing local musicians who are committed to sustainable practices, with eco-friendly merchandise and catering options",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14 
                  ),
                )
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10))
            ],
          ),
        ),
      );
  }
}