import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_tab.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;

class WeeklyMissionsTabView extends StatelessWidget {
  final List<MissionEntity> missions;
  const WeeklyMissionsTabView({Key? key, required this.missions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int day = DateTime.now().weekday;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildHeader("Weekly"),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Week Progress",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildProgressBar(day),
              const SizedBox(height: 16),
              Text(
                "Missions",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildMissionsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProgressBar(int day) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        minHeight: 20,
        value: day / 7,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
      ),
    );
  }

  Widget _buildMissionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        return MissionTab(
          mission: missions[index],
          index: index + 1,
        );
      },
    );
  }
}