import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';

class ProfileHeader extends StatelessWidget {
  final ProactUser user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
