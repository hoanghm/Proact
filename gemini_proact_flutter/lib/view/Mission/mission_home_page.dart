import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getUserActiveProjects, completeMissionById, getUserWeeklyEcoPoints, getMissionById;
import 'package:gemini_proact_flutter/model/database/user.dart' show ProactUser;
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;
import 'package:gemini_proact_flutter/view/Mission/components/home_card.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
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
  int currEcoPoints = 0;
  int currLevel = 1;
  bool isLoading = true;
  void updateStatistics(int points) {
    int ecoPoints = currEcoPoints + points;
    if (ecoPoints < 0) {
      ecoPoints = 0;
    }
    setState(() {
      currEcoPoints = ecoPoints;
      currLevel = ecoPoints ~/ 100 + 1;
    });
  }
  void refreshMission () async {
    List<MissionEntity>? missions = await getUserActiveProjects(user: widget.user, depth: 2);
    int ecoPoints = await getUserWeeklyEcoPoints(widget.user);
    if (missions == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      activeMissions = missions;
      currEcoPoints = ecoPoints;
      currLevel = ecoPoints ~/ 100 + 1;
      isLoading = false;
    });
  }
  void getUserMissions () async {
    List<MissionEntity>? missions = await getUserActiveProjects(user: widget.user, depth: 2);
    int ecoPoints = await getUserWeeklyEcoPoints(widget.user);
    if (missions == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      activeMissions = missions;
      currEcoPoints = ecoPoints;
      currLevel = ecoPoints ~/ 100 + 1;
      isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserMissions();
    });
  }

  void onSubmit(Map<String, dynamic> submissionDetails) {
    // Update points
    int rewardAmount = submissionDetails["rewardAmount"];
    setState(() {
      currEcoPoints += rewardAmount;
      currLevel = currEcoPoints ~/ 100;
    });

    // Complete mission on Firebase
    String missionId = submissionDetails["missionId"];
    completeMissionById(missionId);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ) 
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProactLogo(size: 26)
            ],
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          HomeCard(
            currentEcoPoints: currEcoPoints, 
            currentLevel: currLevel
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          WeeklyMissionsTabView(missions: activeMissions, callback: onSubmit, stepCallback: updateStatistics, ecoPoints: currEcoPoints, level: currLevel, onRefreshCallback: refreshMission),
          const SizedBox(height: 10)
        ],
      )
    );
  }
}