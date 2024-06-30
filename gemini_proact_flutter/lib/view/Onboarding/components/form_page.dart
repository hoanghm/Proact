import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/Onboarding/input_field_generator.dart';

import 'package:gemini_proact_flutter/view/Onboarding/components/form_next_button.dart';
class FormPage extends StatefulWidget {
  final List<Map<String, String>> formFields;
  const FormPage({super.key, required this.formFields});

  @override
  FormPageState createState() {
    return FormPageState();
  }
}

class FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _textControllers = [];

  @override
  Widget build (BuildContext context) {
    void validateFormFields() {
      String output = "";
      for (int i = 0; i < _textControllers.length; i++) {
        output += '${widget.formFields[i]["question"]!}: ${_textControllers[i].text}\n';
      }
      if (_formKey.currentState!.validate()) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => Scaffold(
            body: Center(
              child: Text(output)
            ),
          ))
        );    
      }
    }
    
    return SafeArea(
      child: SingleChildScrollView (
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ...generateFormFields(widget.formFields, _textControllers), 
              FormNextButton(onCallback: validateFormFields)
            ]
          )
        ),
      )
    );
  }
}