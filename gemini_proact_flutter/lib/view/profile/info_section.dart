import 'package:flutter/material.dart';

class InfoSection extends StatelessWidget {
  final String? occupation;
  final Map<String, dynamic>? location;

  InfoSection({this.occupation, this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoItem('Occupation', occupation),
        _buildInfoItem('Location', _formatLocation()),
      ],
    );
  }

  Widget _buildInfoItem(String title, String? content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(content ?? 'N/A'),
        ],
      ),
    );
  }

  String? _formatLocation() {
    if (location == null) return null;
    return '${location!['long']}, ${location!['lat']}';
  }
}