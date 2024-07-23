import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildProgressCircle(),
            const SizedBox(width: 20),
            Expanded(child: _buildInfoColumn()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CO₂',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Icon(Icons.arrow_upward, size: 24, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(Icons.scale, '50 Metric'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.person, 'Recruit'),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.title, 'Title'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}