import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/model/Onboarding/input_field_generator.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:gemini_proact_flutter/view/Onboarding/components/form_add_fields.dart';
import 'package:gemini_proact_flutter/view/home/home_page.dart';
import 'package:gemini_proact_flutter/view/Onboarding/components/form_text_field.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_next_button.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getOnboardingQuestions, updateUser;
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart' show Logger;

final logger = Logger((FormPage).toString());

class FormPage extends StatefulWidget {
  final ProactUser user;
  const FormPage({super.key, required this.user});
  
  @override
  FormPageState createState() {
    return FormPageState();
  }
}

class FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  /// Static form fields
  final List<Map<String, dynamic>> _staticFields = [
    {"question": "Full Name", "fieldType": TextInputType.name, "description": "username"},
    {"question": "Occupation", "fieldType": TextInputType.text, "description": "occupation"},
    {"question": "Location", "fieldType": TextInputType.text, "description": "location"}
  ];
  List<TextEditingController> _staticTextControllers = [];
  final List<TextEditingController> _interestsTextControllers = [];
  final List<TextEditingController> _othersTextControllers = [];
  final List<TextEditingController> _dynamictextControllers = [];
  List<Question> onboardingQuestions = []; 

  /// Fill initial fields given field name in Firebase
  String getUserField(String field) {
    switch (field) {
      case "username":
        return widget.user.username;
      case "occupation":
        return widget.user.occupation;
      case "location":
        return widget.user.location;
    }
    return "";
  }

  void loadOnboardingQuestions () async {
    List<Question> questions = await getOnboardingQuestions();
    setState(() {
      _staticTextControllers = [... List.generate(3, (int index) => TextEditingController())];
      onboardingQuestions = questions;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // logger.info(widget.user.username);
      loadOnboardingQuestions();
    });
  }

  @override
  Widget build (BuildContext context) {
    void validateFormFields() {
      Map<String, Object> formSubmission = {
        "email": widget.user.email, 
        "questionnaire": widget.user.questionnaire, 
        "onboarded": true, 
      };
      /// Check Static Form Fields
      for (int i = 0; i < _staticTextControllers.length; i++) {
        formSubmission[_staticFields[i]["description"]] = _staticTextControllers[i].text;
      }
      /// Check Interests Fields
      List<dynamic> interests = [];
      for (int i = 0; i < _interestsTextControllers.length; i++) {
        String text = _interestsTextControllers[i].text;
        if (text.isEmpty) {
          continue;
        }
        interests.add(text);
      }
      formSubmission["interests"] = interests;
      /// Check Others Fields
      List<dynamic> others = [];
      for (int i = 0; i < _othersTextControllers.length; i++) {
        String text = _othersTextControllers[i].text;
        if (text.isEmpty) {
          continue;
        }
        others.add(text);
      }
      formSubmission["others"] = others;
      List<Map<String, Object>> questionSubmission = [];
      for (int i = 0; i < _dynamictextControllers.length && i < onboardingQuestions.length; i++) {
        String questionId = onboardingQuestions[i].id;
        String answer = _dynamictextControllers[i].text;
        questionSubmission.add({"questionId": questionId, "answer": answer});
      }
      logger.info(interests);
      // if (_formKey.currentState!.validate()) {
      //   updateUser(formSubmission, questionSubmission, widget.user.questionnaire)
      //     .then((_) {
      //       Navigator.push(
      //         context, 
      //         MaterialPageRoute(builder: (context) => const Scaffold(
      //           body: HomePage()
      //         ))
      //       );   
      //     }); 
      // }
    }
    
    return SafeArea(
      child: SingleChildScrollView (
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProactLogo(),
              Text(
                "Please answer some questions for more personalized results", 
                style: GoogleFonts.spaceGrotesk(fontSize: 16),
                textAlign: TextAlign.center
              ),
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              for (int i = 0; i < _staticFields.length && i < _staticTextControllers.length; i++) 
                Column(
                  children: [
                    FormTextField(
                      question: _staticFields[i]["question"], 
                      initialText: getUserField(_staticFields[i]["description"]),
                      fieldType: _staticFields[i]["fieldType"], 
                      controller: _staticTextControllers[i], 
                      required: true
                    ),
                    const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10))
                  ],
                ),
              FormAddField(required: true, controllers: _interestsTextControllers, initialTexts: widget.user.interests),
              FormAddField(required: false, controllers: _othersTextControllers, initialTexts: widget.user.others),
              ...questionsToFormFields(onboardingQuestions, _dynamictextControllers, widget.user.questionnaire), 
              const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              FormNextButton(onCallback: validateFormFields)
            ]
          )
        ),
      )
    );
  }
}