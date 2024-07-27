import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;

class WeeklyMissionsTabView extends StatefulWidget {
  final List<MissionEntity> missions;
  const WeeklyMissionsTabView({super.key, required this.missions});

  @override 
  WeeklyMissionsTabViewState createState() {
    return WeeklyMissionsTabViewState();
  }
}

class WeeklyMissionsTabViewState extends State<WeeklyMissionsTabView> {
  final int day = DateTime.now().weekday;
  
  @override
  Widget build (BuildContext context) {
    return Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 25),
                padding: const EdgeInsets.only(left: 25, right: 25), 
                decoration: const BoxDecoration(
                  color: Colors.yellow
                ),
                child: Text(
                  "Weekly",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  width: double.infinity,
                  color: Colors.yellow,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 20)),
                        FractionallySizedBox(
                          widthFactor: 0.8,
                          child: LinearProgressIndicator(
                            minHeight: 30,
                            value: day / 7,
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 20)),
                        for (int i = 0; i < widget.missions.length; i++) 
                          MissionTab(
                            mission: widget.missions[i],
                            index: i + 1,
                          ),
                          const Padding(padding: EdgeInsets.only(top: 20))                    
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        )
      ),
    );
  }
}