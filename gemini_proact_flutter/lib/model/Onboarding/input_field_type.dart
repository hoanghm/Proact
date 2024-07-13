import 'package:flutter/material.dart';
enum InputFieldTypes {
  number,
  yesNo,
  name,
  email,
  address,
  shortAnswer,
  
}

InputFieldTypes strToFieldType(String type) {
  InputFieldTypes enumType = InputFieldTypes.values.firstWhere((value) => value.name == type);
  return enumType;
}

TextInputType getKeyboardType(InputFieldTypes type) {
  switch (type) {
    case InputFieldTypes.number:
      return TextInputType.number;
    case InputFieldTypes.yesNo:
      return TextInputType.none;
    case InputFieldTypes.name:
      return TextInputType.name;
    case InputFieldTypes.email:
      return TextInputType.emailAddress;
    case InputFieldTypes.address:
      return TextInputType.streetAddress;
    default:
      return TextInputType.text;
  }
}