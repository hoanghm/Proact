import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_text_field.dart';
import 'package:logging/logging.dart' show Logger;

final logger = Logger((FormAddField).toString());
class FormAddField extends StatefulWidget {
  final bool required;
  final List<dynamic> initialTexts;
  final List<TextEditingController> controllers;
  const FormAddField({super.key, required this.required, required this.controllers, required this.initialTexts});

  @override
  FormAddFieldState createState() {
    return FormAddFieldState();
  }
}

class FormAddFieldState extends State<FormAddField> {
  // Colors
  final Color addButtonColor = const Color.fromRGBO(153, 107, 64, 1);
  final Color submitButtonColor = const Color.fromRGBO(89, 155, 67, 1);
  final Color grey = const Color.fromRGBO(156, 156, 156, 1);
  
  // State
  List<TextEditingController> textControllers = [];
  List<FormTextField> textFields = [];
  void addTextField() {
    setState(() {
      widget.controllers.add(TextEditingController());
      int index = widget.controllers.length - 1;
      textFields.add(FormTextField(question: "", initialText: "", fieldType: TextInputType.text, controller: widget.controllers[index], required: false));
    });
  }
  @override
  void initState() {
    super.initState();
    setState(() {
      for (int i = 0; i < widget.initialTexts.length; i++) {
        
        String initialText = widget.initialTexts[i];
        widget.controllers.add(TextEditingController());
        int index = widget.controllers.length - 1;
        textFields.add(FormTextField(question: "", initialText: initialText, fieldType: TextInputType.text, controller: widget.controllers[index], required: false));
      }
    });
  }

  // Renders
  @override
  Widget build(BuildContext context) {
    String displayText = widget.required ? "What are your interests?" : "Anything else to add?";
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(
              displayText,
              style: const TextStyle(color: Colors.black, fontSize: 16)
            )
          )
        ),
        Column(  
          children: [
            ...textFields
          ],
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 4)
              )
            ]
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: addButtonColor,
            ),
            onPressed: () {
              addTextField();
            }, 
            child: const Text(
              "Add",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10))
      ],
    );
  }
}