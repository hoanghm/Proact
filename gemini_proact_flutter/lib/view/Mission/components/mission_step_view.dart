import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/mission_step_tab.dart';

class MissionStepView extends StatefulWidget {
  const MissionStepView({super.key});
  
  @override
  MissionStepViewState createState() {
    return MissionStepViewState();
  }
}

class MissionStepViewState extends State<MissionStepView> {
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
              MissionStepTab(stepDescription: "Research local restaurants that use sustainable ingredients and reduce food waste."),
              const Padding(padding: EdgeInsets.only(top: 10)),
              MissionStepTab(stepDescription: "Research local restaurants that use sustainable ingredients and reduce food waste."),
              const Padding(padding: EdgeInsets.only(top: 10))
            ],
          )
        ),
      ),
    );
  }
}