import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionTab extends StatelessWidget {
  const MissionTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MissionPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTag("Mission 1", Colors.blue.shade100),
                    _buildTag("CO₂ High", Colors.green.shade100),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Organize a 'Green Gig' event showcasing local musicians who are committed to sustainable practices, with eco-friendly merchandise and catering options",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}