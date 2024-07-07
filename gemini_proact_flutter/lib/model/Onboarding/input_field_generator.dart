import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/model/onboarding/input_field_type.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_text_field.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_toggle_button.dart';

Widget questionToFormField(Question question, List<TextEditingController> controllers) {
  InputFieldTypes type = strToFieldType(question.type);
  switch (type) {
    case InputFieldTypes.yesNo:
      final newController = TextEditingController();
      controllers.add(newController);
      return FormToggleButton(question: question.title, controller: newController);
    default:
      final newController = TextEditingController();
      controllers.add(newController);
      return FormTextField(question: question.title, initialText: "", fieldType: getKeyboardType(type), controller: newController, required: question.mandatory);
  }
}

List<Widget> questionsToFormFields(List<Question> questions, List<TextEditingController> controllers) {
  List<Widget> generatedFields = [];
  for (int i = 0; i < questions.length; i++) {
    Question question = questions[i];
    Widget generatedField = questionToFormField(question, controllers);
    generatedFields.add(generatedField);
    if (i != questions.length - 1) {
      generatedFields.add(const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)));
    }   
  }
  
  return generatedFields;
}