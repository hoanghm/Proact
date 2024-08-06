import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_progress_card.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_step_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity, MissionStatus;
import 'package:gemini_proact_flutter/model/database/firestore.dart' show setStepStatusById;

class MissionPage extends StatefulWidget {
  final MissionEntity mission;
  final int ecoPoints;
  final int level;
  final void Function(int) stepCallback;
  const MissionPage({super.key, required this.mission, required this.ecoPoints, required this.level, required this.stepCallback});
  @override
  MissionPageState createState() {
    return MissionPageState();
  }
}

class MissionPageState extends State<MissionPage> {
  int currStep = 0;
  int totalSteps = 1;
  int rewardAmount = 0;
  String stepDescription = "";

  void updateStepsCompleted(bool newState) {
    int value = currStep;
    if (newState) {
      value++;
    } else {
      value--;
    }

    if (value < 0) {
      value = 0;
    }

    if (value > totalSteps) {
      value = totalSteps;
    }
    
    bool completedMission = value >= totalSteps;
    int newRewardAmount = completedMission ? rewardAmount : -rewardAmount;
    widget.stepCallback(newRewardAmount);
    setStepStatusById(widget.mission.id, completedMission);

    setState(() {
      currStep = value;
    });
  }


  @override
  void initState() {
    super.initState();
    
    int numStepsCompleted = 0;
    for (int i = 0; i < widget.mission.steps.length; i++) {
      if (widget.mission.steps[i].status == MissionStatus.done) {
        numStepsCompleted++;
      }
    }
    setState(() {
        currStep = numStepsCompleted;
        totalSteps = widget.mission.steps.length;
        rewardAmount = widget.mission.ecoPoints;
        stepDescription = widget.mission.description ?? "";
      } 
    );
  }
  
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.mission.title,
          style: GoogleFonts.spaceGrotesk(
          )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {
            Navigator.of(context).pop()
          },
        ), 
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
            MissionStepView(
              steps: widget.mission.steps,
              onStepChange: updateStepsCompleted,
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            // Container(
            //   margin: const EdgeInsets.all(25),
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       disabledBackgroundColor: Colors.grey,
            //       backgroundColor: Colors.green,
            //       foregroundColor: Colors.white
            //     ),
                
            //     onPressed: currStep < totalSteps ? null : () {
            //       Navigator.pop(context, 
            //         {
            //           "rewardAmount": rewardAmount,
            //           "missionId": widget.mission.id
            //         }
            //       );
            //     },
            //     child: Text(
            //       "Submit",
            //       style: GoogleFonts.spaceGrotesk(
            //         fontSize: 20
            //       ),
            //     ),
            //   ),
            // )
            // Container(
            //   margin: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Column(
            //     children: [
            //       Text(
            //         "Mission Photos",
            //         style: GoogleFonts.spaceGrotesk(
            //           fontSize: 16,
            //           decoration: TextDecoration.underline
            //         ),
            //       ),
            //       const Padding(padding: EdgeInsets.only(top: 10)),
            //       SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: Row(
            //           children: [
            //             Container(
            //               width: 50,
            //               height: 50,
            //               color: Colors.grey,
            //             ),
            //             const Padding(padding: EdgeInsets.only(right: 10)),    
            //             Container(
            //               width: 50,
            //               height: 50,
            //               color: Colors.grey,
            //             ),
            //             const Padding(padding: EdgeInsets.only(right: 10)),
            //             Container(
            //               width: 50,
            //               height: 50,
            //               decoration: const BoxDecoration(
            //                 color: Colors.grey
            //               ),
            //               child: const Icon(
            //                 Icons.add,
            //                 size: 50,
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //       const Padding(padding: EdgeInsets.only(top: 20))
            //     ],
            //   ),
            // )
          ],
        ),
      )
    );
  }
}