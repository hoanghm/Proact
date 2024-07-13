import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsSection extends StatelessWidget {
  final String userId;

  EventsSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('userEvents').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<QueryDocumentSnapshot> events = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Events', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Column(
              children: events.map((event) => _buildEventItem(event)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventItem(QueryDocumentSnapshot event) {
    Map<String, dynamic> eventData = event.data() as Map<String, dynamic>;
    return ListTile(
      title: Text(eventData['title'] ?? ''),
      subtitle: Text(eventData['description'] ?? ''),
      trailing: Text(eventData['startDateTime'] ?? ''),
    );
  }
}