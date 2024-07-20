import 'package:flutter/material.dart';

class EditFieldDialog extends StatelessWidget {
  final String title;
  final String currentValue;
  final ValueChanged<String> onSave;

  const EditFieldDialog({
    super.key,
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    String newValue = currentValue;
    return AlertDialog(
      title: Text('Edit $title'),
      content: TextField(
        onChanged: (value) => newValue = value,
        controller: TextEditingController(text: currentValue),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            onSave(newValue);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class EditInterestsDialog extends StatefulWidget {
  final List<String> currentInterests;
  final ValueChanged<List<String>> onSave;

  const EditInterestsDialog({
    super.key,
    required this.currentInterests,
    required this.onSave,
  });

  @override
  _EditInterestsDialogState createState() => _EditInterestsDialogState();
}

class _EditInterestsDialogState extends State<EditInterestsDialog> {
  late List<String> newInterests;

  @override
  void initState() {
    super.initState();
    newInterests = List.from(widget.currentInterests);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Interests'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            ...newInterests.map((interest) => ListTile(
              title: Text(interest),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    newInterests.remove(interest);
                  });
                },
              ),
            )),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add new interest'),
              onTap: () async {
                final newInterest = await _addNewInterest(context);
                if (newInterest != null && newInterest.isNotEmpty) {
                  setState(() {
                    newInterests.add(newInterest);
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            widget.onSave(newInterests);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<String?> _addNewInterest(BuildContext context) async {
    String newInterest = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Interest'),
          content: TextField(
            onChanged: (value) => newInterest = value,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(newInterest);
              },
            ),
          ],
        );
      },
    );
  }
}
