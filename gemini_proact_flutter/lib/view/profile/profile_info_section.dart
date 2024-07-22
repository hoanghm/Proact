import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_edit_dialogs.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onEdit;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.value,
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
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editField(context),
        ),
      ],
    );
  }

  void _editField(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return EditFieldDialog(
          title: title,
          currentValue: value,
          onSave: onEdit,
        );
      },
    );
  }
}
