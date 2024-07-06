import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/Onboarding/input_field_generator.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_next_button.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getOnboardingQuestions;

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  FormPageState createState() {
    return FormPageState();
  }
}

class FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _textControllers = [];
  List<Question> onboardingQuestions = []; 

  void loadOnboardingQuestions () async {
    List<Question> questions = await getOnboardingQuestions();
    setState(() {
      onboardingQuestions = questions;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadOnboardingQuestions();
    });
  }
  @override
  Widget build (BuildContext context) {
    void validateFormFields() {
      String output = "";
      for (int i = 0; i < _textControllers.length; i++) {
        output += '${onboardingQuestions[i].title}: ${_textControllers[i].text}\n';
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
              ...questionsToFormFields(onboardingQuestions, _textControllers), 
              FormNextButton(onCallback: validateFormFields)
            ]
          )
        ),
      )
    );
  }
}