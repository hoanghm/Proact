import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_edit_dialogs.dart';

class ProfileInterestsSection extends StatelessWidget {
  final List<String> interests;
  final ValueChanged<List<String>> onEdit;

  const ProfileInterestsSection({
    super.key,
    required this.interests,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(context),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: interests.map((interest) => Chip(
                label: Text(interest),
                backgroundColor: Colors.blue.shade100,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Interests', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editInterests(context),
        ),
      ],
    );
  }

  void _editInterests(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EditInterestsDialog(
          currentInterests: interests,
          onSave: onEdit,
        );
      },
    );
  }
}
