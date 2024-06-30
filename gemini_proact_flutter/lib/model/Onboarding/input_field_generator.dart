import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/onboarding/input_field_type.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_text_field.dart';
import 'package:gemini_proact_flutter/view/onboarding/components/form_toggle_button.dart';

Widget generateFormField(String question, String required, InputFieldTypes type, List<TextEditingController> controllers) {
  switch (type) {
    case InputFieldTypes.yesNo:
      final newController = TextEditingController();
      controllers.add(newController);
      return FormToggleButton(question: question, controller: newController);
    default:
      final newController = TextEditingController();
      bool isRequired = required == "yes";
      controllers.add(newController);
      return FormTextField(question: question, fieldType: getKeyboardType(type), controller: newController, required: isRequired);
  }
}

List<Widget> generateFormFields(List<Map<String, String>> fields, List<TextEditingController> controllers) {
  List<Widget> generatedFields = [];
  for (int i = 0; i < fields.length; i++) {
    dynamic field = fields[i];  
    String question = field['question']!;
    String required = field['required'] == null ? "no" : field["required"];
    InputFieldTypes type = strToFieldType(field['type']!);
    Widget widget = generateFormField(question, required, type, controllers);
    generatedFields.add(widget);
    if (i != fields.length - 1) {
      generatedFields.add(const SizedBox(height: 10));
    }
  }
  
  return generatedFields;
}