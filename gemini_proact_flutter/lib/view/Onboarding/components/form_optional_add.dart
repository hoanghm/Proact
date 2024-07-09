import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_text_field.dart';

class FormOptionalAdd extends StatefulWidget {
  const FormOptionalAdd({super.key});

  @override
  FormOptionalAddState createState() {
    return FormOptionalAddState();
  }
}

class FormOptionalAddState extends State<FormOptionalAdd> {
  // Colors
  final Color addButtonColor = const Color.fromRGBO(153, 107, 64, 1);
  final Color submitButtonColor = const Color.fromRGBO(89, 155, 67, 1);
  final Color grey = const Color.fromRGBO(156, 156, 156, 1);
  
  // State
  List<TextEditingController> textControllers = [];
  List<FormTextField> textFields = [];
  void addTextField() {
    setState(() {
      textControllers.add(TextEditingController());
      int index = textControllers.length - 1;
      textFields.add(FormTextField(question: "", initialText: "",fieldType: TextInputType.text, controller: textControllers[index], required: false));
    });
  }

  // Renders
  @override
  Widget build(BuildContext context) {

    void submitOptionalInfo() {
      String output = "";
      for (int i = 0; i < textControllers.length; i++) {
        String text = textControllers[i].text;
        if (text.isNotEmpty) {
          output += '$text\n';
        }
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => 
          Scaffold(
            body: Center(
              child: Text(output),
            ),
          )
        )
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
        children: [
          const Text(
            "PROACT",
            style: TextStyle(
              fontSize: 32,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  offset: Offset(0, 4)
                )
              ]
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
          const Text(
            "Please enter anything you think is relevant.",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
          Text(
            "ex: I like to be more active, I would like to meet more people",
            style:  TextStyle(
              fontSize: 12,
              color: grey
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 30)),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: const Text(
                "optional", 
                style: TextStyle(color: Colors.red)
              )
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(  
              children: [
                ...textFields
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
          Container(
            width: 150,
            height: 35,
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
          const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40)),
          Container(
              width: 280,
              height: 50,
              decoration: BoxDecoration(
                color: submitButtonColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 4),
                    color: Color.fromRGBO(0, 0, 0, 0.25)
                  )
                ]
              ),
              child: TextButton(
                onPressed: () {
                  submitOptionalInfo();
                },
                child: const Text(
                  "Finish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                  ),
                )
              ),
            )
        ],
      )
      ),
    );
  }
}