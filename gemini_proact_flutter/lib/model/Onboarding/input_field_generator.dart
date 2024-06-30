import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/Onboarding/input_field_type.dart';
import 'package:gemini_proact_flutter/view/Onboarding/components/form_text_field.dart';
import 'package:gemini_proact_flutter/view/Onboarding/components/form_toggle_button.dart';

Widget generateFormField(String question, InputFieldTypes type, List<TextEditingController> controllers) {
  switch (type) {
    case InputFieldTypes.yesNo:
      final newController = TextEditingController();
      controllers.add(newController);
      return FormToggleButton(question: question, controller: newController);
    default:
      final newController = TextEditingController();
      controllers.add(newController);
      return FormTextField(question: question, fieldType: getKeyboardType(type), controller: newController);
  }
}

List<Widget> generateFormFields(List<Map<String, String>> fields, List<TextEditingController> controllers) {
  List<Widget> generatedFields = [];
  for (int i = 0; i < fields.length; i++) {
    dynamic field = fields[i];  
    String question = field['question']!;
    InputFieldTypes type = strToFieldType(field['type']!);
    Widget widget = generateFormField(question, type, controllers);
    generatedFields.add(widget);
    if (i != fields.length - 1) {
      generatedFields.add(const SizedBox(height: 10));
    }
  }
  
  return generatedFields;
}