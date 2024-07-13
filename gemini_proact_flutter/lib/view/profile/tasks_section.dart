import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TasksSection extends StatelessWidget {
  final String userId;

  TasksSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('userTasks').where('userId', isEqualTo: userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        List<QueryDocumentSnapshot> tasks = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasks', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            Column(
              children: tasks.map((task) => _buildTaskItem(task)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(QueryDocumentSnapshot task) {
    Map<String, dynamic> taskData = task.data() as Map<String, dynamic>;
    return ListTile(
      title: Text(taskData['title'] ?? ''),
      subtitle: Text(taskData['description'] ?? ''),
      trailing: Chip(label: Text(taskData['status'] ?? '')),
    );
  }
}