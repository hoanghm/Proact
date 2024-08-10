import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;
import 'package:logging/logging.dart' show Logger;

final logger = Logger((WeeklyMissionsTabView).toString());
class WeeklyMissionsTabView extends StatefulWidget {
  final List<MissionEntity> missions;
  final void Function(Map<String, dynamic>) callback;
  final void Function(int) stepCallback;
  final int ecoPoints;
  final int level;
  const WeeklyMissionsTabView({super.key, required this.missions, required this.callback, required this.stepCallback, required this.ecoPoints, required this.level});

  @override 
  WeeklyMissionsTabViewState createState() {
    return WeeklyMissionsTabViewState();
  }
}

class WeeklyMissionsTabViewState extends State<WeeklyMissionsTabView> {
  final int day = DateTime.now().weekday;
  @override
  void initState() {
    super.initState();
  }
  List<Widget> getWeeklyMissions() {
    int index = 1;
    List<Widget> temp = [];
    for (int i = 0; i < widget.missions.length; i++) {
      for (int j = 0; j < widget.missions[i].steps.length; j++) {
        temp.add(
          MissionTab(
            mission: widget.missions[i].steps[j],
            index: index,
            callback: widget.callback,
            ecoPoints: widget.ecoPoints,
            level: widget.level,
            stepCallback: widget.stepCallback
          )
        );
        temp.add(const Padding(padding: EdgeInsets.only(top: 20)));
        index++;
      }
    }
    return temp;
  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Weekly Missions',
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: day / 7,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build (BuildContext context) {
    List<Widget> weeklyMissions = getWeeklyMissions();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildProgressBar(),
          const SizedBox(height: 24),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ...weeklyMissions
            ]
          )
        ],
      ),
    );
  }
}