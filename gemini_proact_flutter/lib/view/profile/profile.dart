import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/user.dart' show ProactUser;
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show signOutUser;
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getUser, updateUserOccupation, updateUserInterests;

class Profile extends StatefulWidget {
  final ProactUser user;
  const Profile({super.key, required this.user});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  late Future<ProactUser?> userFuture;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    userFuture = _fetchUser();
  }

  Future<ProactUser?> _fetchUser() async {
    return getUser();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: FutureBuilder<ProactUser?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('User not found'));
          }

          final userData = snapshot.data!;

          return CustomScrollView(
            slivers: [
              _buildAppBar(userData),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildInfoSection('Occupation', userData.occupation),
                    _buildInterestsSection(userData.interests ?? []),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ProactUser user) {
    return SliverAppBar(
      expandedHeight: 125,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          margin: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                user.email,
                style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.black),
              )
            ],
          ),
        ),
        background: Image.network(
          "https://images.unsplash.com/photo-1579546929518-9e396f3cc809",
          fit: BoxFit.cover,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, size: 30),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            signOutUser();
          },
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return _buildCard(
      title: title,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(title, () => _editField(title, value)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(List<dynamic> interests) {
    return _buildCard(
      title: 'Interests',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow('Interests', () => _editInterests(interests)),
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
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      ),
    );
  }

  Widget _buildTitleRow(String title, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ],
    );
  }

  void _editField(String field, String currentValue) {
    showDialog(
      context: context,
      builder: (context) {
        String newValue = currentValue;
        return AlertDialog(
          title: Text('Edit $field'),
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
                updateUserOccupation(newValue).then((_) {
                  Navigator.of(context).pop();
                  setState(() {
                    userFuture = _fetchUser(); // Refresh the user data
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _editInterests(List<dynamic> currentInterests) {
  showDialog(
    context: context,
    builder: (context) {
      List<String> newInterests = List.from(currentInterests);
      return StatefulBuilder(
        builder: (context, setStateBuilder) {
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
                        setStateBuilder(() {
                          newInterests.remove(interest);
                        });
                      },
                    ),
                  )),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add new interest'),
                    onTap: () {
                      // Implement adding a new interest
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String newInterest = '';
                          return AlertDialog(
                            title: const Text('Add New Interest'),
                            content: TextField(
                              autofocus: true,
                              onChanged: (value) {
                                newInterest = value;
                              },
                              decoration: const InputDecoration(hintText: "Enter new interest"),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Add'),
                                onPressed: () {
                                  if (newInterest.isNotEmpty) {
                                    setStateBuilder(() {
                                      newInterests.add(newInterest); // Refresh the user data
                                    });
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
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
                  // Implement updating the user's interests
                  updateUserInterests(newInterests).then((_) {
                    Navigator.of(context).pop();
                    setStateBuilder(() {
                      userFuture = _fetchUser(); // Refresh the user data
                    });
                    setState(() {
                      userFuture = _fetchUser(); // Refresh the user data
                    });
                  });
                },
              ),
            ],
          );
          }
        );
      },
    );
  }
}
