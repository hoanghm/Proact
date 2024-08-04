import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionStepTab extends StatefulWidget {
  final String stepDescription;
  final String stepId;
  final bool initCheckState;
  final int index;
  final void Function(bool, String, int) onCheckboxPress;
  const MissionStepTab({super.key, required this.stepDescription, required this.initCheckState, required this.index, required this.onCheckboxPress, required this.stepId});
  
  @override
  MissionStepTabState createState() {
    return MissionStepTabState();
  }
}

class MissionStepTabState extends State<MissionStepTab> {
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isChecked = widget.initCheckState;
    });
  }

  Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.5,
            child: Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(getColor),
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
                widget.onCheckboxPress(value!, widget.stepId, widget.index);
              },
            ),
          ),
          Flexible(
            child: Text(
              widget.stepDescription,
              textAlign: TextAlign.start,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16
              ),
            )
          )
        ],
      ),
    );
  }
}