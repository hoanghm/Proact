import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;

class MissionTab extends StatefulWidget {
  final MissionEntity mission;  
  final int index;
  const MissionTab({super.key, required this.mission, required this.index});

  @override
  MissionTabState createState() {
    return MissionTabState();
  }
}

class MissionTabState extends State<MissionTab> with AutomaticKeepAliveClientMixin<MissionTab> {
  @override
  Widget build (BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MissionPage(mission: widget.mission)) 
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
                    'Mission ${widget.index}',
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
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'CO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18
                          )
                        ),
                        const TextSpan(
                          text: '2',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFeatures: [FontFeature.subscripts()]
                          )
                        ),
                        TextSpan(
                          text: ' ${widget.mission.CO2InKg}',
                          style: const TextStyle(
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
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Text(
                widget.mission.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20 
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}