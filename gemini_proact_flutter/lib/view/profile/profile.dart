import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  ProfileState createState() {
    return ProfileState();
  }
}

class ProfileState extends State<Profile> {
 @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Text(
                  "Welcome, Moyesh!",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                  )
                )
              ),
              const Spacer(flex: 1),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: const Image(
                    image: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                    width: 50,
                    height: 50
                  )
                )
              )
            ],
          ),
          Container(margin: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(60, 232, 149, 1),
                    Color.fromRGBO(21, 111, 62, 1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.circular(25)
              ),  
            )
          ),
          Container(margin: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(60, 232, 149, 1),
                        Color.fromRGBO(21, 111, 62, 1)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    ),
                    borderRadius: BorderRadius.circular(25)
                  )
                  )
                ),
                Container(width: 10),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(60, 232, 149, 1),
                        Color.fromRGBO(21, 111, 62, 1)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    ),
                    borderRadius: BorderRadius.circular(25)
                    )
                  )
                )        
              ],
            ),
          ),
          Container(margin: const EdgeInsets.fromLTRB(0, 15, 0, 0)),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(60, 232, 149, 1),
                  Color.fromRGBO(21, 111, 62, 1)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              ),
              borderRadius: BorderRadius.circular(25)
              )
            )
          )
        ],
      )
    );
  }
}