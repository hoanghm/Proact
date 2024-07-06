import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_optional_add.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_page.dart';
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getOnboardingQuestions;
import 'package:logging/logging.dart' show Logger;

final logger = Logger((OnboardingForm).toString());
class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() {
    return _OnboardingFormState();
  }
}

class _OnboardingFormState extends State<OnboardingForm> {
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
    return const Scaffold(
      body: SafeArea(
        child: FormPage()
      )
    );
  }
}