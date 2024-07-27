import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getUserActiveProjects;
import 'package:gemini_proact_flutter/model/database/user.dart' show ProactUser;
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;
import 'package:gemini_proact_flutter/view/Mission/components/home_card.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/view/Mission/components/weekly_missions_tab_view.dart';
import 'package:logging/logging.dart' show Logger;

final logger = Logger((MissionHomePage).toString());

class MissionHomePage extends StatefulWidget {
  final ProactUser user;
  const MissionHomePage({super.key, required this.user});

  @override
  MissionHomePageState createState() {
    return MissionHomePageState();
  }
}

class MissionHomePageState extends State<MissionHomePage> {
  List<MissionEntity> activeMissions = [];
  void getUserMissions () async {
    List<MissionEntity>? missions = await getUserActiveProjects(user: widget.user, depth: 1);
    if (missions == null) {
      return;
    }
    logger.info(missions.first.steps);
    setState(() {
      activeMissions = missions;
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserMissions();
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.user.username, 
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w500
                )),
              ProactLogo(size: 22),
              IconButton(
                onPressed: () {
                  // TODO: Add onPressed functionality for whatever this does
                }, 
                icon: const Icon(
                  Icons.menu,
                  size: 35,
                )
              )
            ],
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          const HomeCard(),
          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          WeeklyMissionsTabView(missions: activeMissions),
          const SizedBox(height: 10)
        ],
      )
    );
  }
}