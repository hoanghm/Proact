import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Onboarding/components/form_page.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  OnboardingFormState createState() {
    return OnboardingFormState();
  }
}

class OnboardingFormState extends State<OnboardingForm> {
  final debugInput = [
    {
      'question': 'Full Name',
      'type': 'name',
      'required': 'yes'
    },
    {
      'question': 'Age',
      'type': 'number',
      'required': 'yes'
    },
    {
      'question': 'Who are you?',
      'type': 'shortAnswer',
      'required': 'no'
    },
    {
      'question': 'Do you have a car?',
      'type': 'yesNo'
    }
  ];
 
  @override
  Widget build (BuildContext context) {
    return SafeArea(
      child: FormPage(formFields: debugInput)
    );
  }
}