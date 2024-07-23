import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/user.dart' show ProactUser;
import 'package:gemini_proact_flutter/view/Mission/components/home_card.dart';
import 'package:gemini_proact_flutter/view/Mission/components/weekly_missions_tab_view.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionHomePage extends StatelessWidget {
  final ProactUser user;
  const MissionHomePage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false,
  centerTitle: true,
  title: Text(
    'Proact',
    style: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: HomeCard(),
            ),
            const SizedBox(height: 24),
            const WeeklyMissionsTabView(),
          ],
        ),
      ),
    );
  }
}