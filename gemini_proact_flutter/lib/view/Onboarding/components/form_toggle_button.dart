import 'package:flutter/material.dart';

class FormToggleButton extends StatefulWidget {
  final String question;
  final TextEditingController controller;
  const FormToggleButton({super.key, required this.question, required this.controller});
  
  @override
  FormToggleButtonState createState() {
    return FormToggleButtonState();
  }
}

class FormToggleButtonState extends State<FormToggleButton> {
  // Constants
  Color lightGrey = const Color.fromRGBO(152, 152, 152, 1);
  Color lightGreen = const Color.fromRGBO(60, 255, 156, 1);
  Color darkGreen = const Color.fromRGBO(38, 164, 100, 1);
  
  // States
  bool isSelected = false;
  @override
  void initState() {
    widget.controller.text = "no";
    super.initState();
  }

  // Render
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.controller.text = isSelected ? "yes" : "no";
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(25)
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(
          children: [
            Text(
              widget.question,
              style: TextStyle(
                color: isSelected ? Colors.white : lightGrey
              ),
            ),
            const Spacer(),
            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: isSelected ? lightGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color.fromRGBO(38, 164, 100, 1)),
                boxShadow: !isSelected ? [] : [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ]
              ),
            )
          ],
        ),
      ),
    );
  }
}