import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormTextField extends StatefulWidget {
  final String question; 
  final String initialText;
  final bool required;
  final TextInputType fieldType;
  final TextEditingController controller;
  const FormTextField({super.key, required this.question, required this.initialText, required this.fieldType, required this.controller, required this.required});
  
  @override
  FormTextFieldState createState() {
    return FormTextFieldState();
  }
}

class FormTextFieldState extends State<FormTextField> {
  final Color lightGrey = const Color.fromRGBO(152, 152, 152, 1);
  String textInput = "";
  
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialText;
  }

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
          if (!widget.required) {
            return null;
          }
          
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
          label: RichText(
            text: TextSpan(
              text: widget.question,
              style: const TextStyle(
                color: Colors.black
              ),
              children: [
                TextSpan(
                  text: widget.required ? " *" : "",
                  style: const TextStyle(
                    color: Colors.red
                  )
                )
              ]
            )
          ),
          labelStyle: const TextStyle(
            color: Colors.black
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