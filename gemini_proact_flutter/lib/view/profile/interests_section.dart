import 'package:flutter/material.dart';

class InterestsSection extends StatelessWidget {
  final List<dynamic>? interests;

  InterestsSection({this.interests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: (interests ?? []).map((interest) => Chip(label: Text(interest))).toList(),
        ),
      ],
    );
  }
}