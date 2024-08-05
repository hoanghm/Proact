import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/view/Mission/components/home_card_label.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildProgressCircle(),
            ),
            Expanded(
              flex: 4,
              child: _buildInfoColumn(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: CircularProgressIndicator(
            strokeWidth: 12,
            value: 0.75,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                children: const [
                  TextSpan(text: 'CO'),
                  TextSpan(
                    text: '2',
                    style: TextStyle(fontFeatures: [FontFeature.subscripts()]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_upward, size: 32, color: Colors.green.shade600),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        HomeCardLabel(label: "50 Metric"),
        SizedBox(height: 12),
        HomeCardLabel(label: "Recruit"),
        SizedBox(height: 12),
        HomeCardLabel(label: "Title"),
      ],
    );
  }
}