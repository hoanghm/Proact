import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_optional_add.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_page.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() {
    return _OnboardingFormState();
  }
}

class _OnboardingFormState extends State<OnboardingForm> {
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
    return const SafeArea(
      // child: FormPage(formFields: debugInput)
      child: FormOptionalAdd()
    );
  }
}