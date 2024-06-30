import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormTextField extends StatefulWidget {
  final String question; 
  final TextInputType fieldType;
  final TextEditingController controller;
  const FormTextField({super.key, required this.question, required this.fieldType, required this.controller});
  
  @override
  FormTextFieldState createState() {
    return FormTextFieldState();
  }

}

class FormTextFieldState extends State<FormTextField> {
  final Color lightGrey = const Color.fromRGBO(152, 152, 152, 1);
  String textInput = "";
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: const Border(
          bottom: BorderSide(
            color: Colors.green
          )
        )
      ),
      child: TextFormField(
        controller: widget.controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter some text";
          } else if (widget.fieldType == TextInputType.number) {
            int parsedValue = int.parse(value);
            if (parsedValue <= 10 || parsedValue >= 90) {
              return "Please enter a reasonable age";
            }
          } else if (widget.fieldType == TextInputType.emailAddress && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Invalid email format";
          }
          return null;
        },
        keyboardType: widget.fieldType,
        inputFormatters: widget.fieldType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: widget.question,
          labelStyle: TextStyle(
            color: lightGrey
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0)
        ),
        onChanged: (String value) {
          setState(() {
            textInput = value;
          });
        },
      ),
    );
  }  
}