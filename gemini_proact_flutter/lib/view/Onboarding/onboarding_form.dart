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
      'type': 'name'
    },
    {
      'question': 'Age',
      'type': 'number'
    },
    {
      'question': 'Who are you?',
      'type': 'shortAnswer'
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