import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_step_tab.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity, MissionStatus;
import 'package:gemini_proact_flutter/model/database/firestore.dart' show setStepStatusById;
import 'package:logging/logging.dart' show Logger;

final logger = Logger((MissionStepView).toString());

class MissionStepView extends StatefulWidget {
  final List<MissionEntity> steps;
  final void Function(bool) onStepChange;
  const MissionStepView({super.key, required this.steps, required this.onStepChange});
  
  @override
  MissionStepViewState createState() {
    return MissionStepViewState();
  }
}

class MissionStepViewState extends State<MissionStepView> {
  @override
  void initState() {
    super.initState();
  }

  void onCheckboxPress (bool status, String missionId, int index) {
    widget.steps[index].status = status ? MissionStatus.done : MissionStatus.notStarted;
    widget.onStepChange(status);
  }

  @override
  Widget build(BuildContext context) {
     return Expanded(
      flex: 1,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 10)),
              for (int i = 0; i < widget.steps.length; i++) 
                MissionStepTab(
                  stepDescription: widget.steps[i].title,
                  stepId: widget.steps[i].id,
                  index: i,
                  initCheckState: widget.steps[i].status.name == "done",           
                  onCheckboxPress: onCheckboxPress,   
                ),
                const Padding(padding: EdgeInsets.only(top: 10)),  
            ],
          )
        ),
      ),
    );
  }
}