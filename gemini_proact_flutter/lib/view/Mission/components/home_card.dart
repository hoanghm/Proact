import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeCard extends StatefulWidget {
  final int currentEcoPoints;
  final int currentLevel;
  const HomeCard({super.key, required this.currentEcoPoints, required this.currentLevel});

  @override
  HomeCardState createState() {
    return HomeCardState();
  }
}

class HomeCardState extends State<HomeCard> {
  void setPlayerStatistics() async {

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPlayerStatistics();
    });
  }

  Widget _buildProgressCircle() {
    return Stack(
      children: [
        const SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: Text(
              'ECO',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28
              )
            ),
          ),
        ),
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            value: (widget.currentEcoPoints % 100) / 100,
            color: Colors.blue,
            backgroundColor: Colors.grey,
          ),
        )
      ],
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoRow(Icons.recycling, 'Level ${widget.currentLevel}'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 30,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build (BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProgressCircle(),
            const SizedBox(width: 20),
            _buildInfoColumn()
          ],
        ),
      ),
    );
  }
}