import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_progress_card.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_step_view.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});
  @override
  MissionPageState createState() {
    return MissionPageState();
  }
}

class MissionPageState extends State<MissionPage> {
  int currStep = 1;
  int totalSteps = 1;
  int rewardAmount = 0;
  String stepDescription = "";

  @override
  void initState() {
    super.initState();
    
    //TODO: Init step count. mission description, and mission reward
    setState(() {
        currStep = 1;
        totalSteps = 2;
        rewardAmount = 50;
        stepDescription = "Many local businesses in California are committed to sustainability. This mission encourages you to support these businesses and promote their efforts.";
      } 
    );
  }
  
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Mission Title",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24
          )
        )
      ),
      body: SafeArea(
        child: Column(
          children: [
            MissionProgressCard(
              currStep: currStep, 
              totalSteps: totalSteps, 
              rewardAmount: rewardAmount, 
              description: stepDescription
            ),
            const Padding(padding: EdgeInsets.only(top: 20)),
            MissionStepView(),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    "Mission Photos",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      decoration: TextDecoration.underline
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                        ),
                        const Padding(padding: EdgeInsets.only(right: 10)),    
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                        ),
                        const Padding(padding: EdgeInsets.only(right: 10)),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.grey
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 50,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 20))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}