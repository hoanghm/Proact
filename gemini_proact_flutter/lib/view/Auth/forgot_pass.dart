import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show forgotPassword, AuthException;
import 'package:logging/logging.dart' show Logger;
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

final logger = Logger((ForgotPass).toString());

class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});
  @override
  ForgotPassState createState() {
    return ForgotPassState();
  }
}

class ForgotPassState extends State<ForgotPass> {
  TextEditingController textEditingController = TextEditingController();
  final Color lightGrey = const Color.fromRGBO(152, 152, 152, 1);
  final Color submitButtonColor = const Color.fromRGBO(89, 155, 67, 1);

  @override
  Widget build(BuildContext context) {
    void showCheckEmailMessage(String errorMessage, String email) {
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            backgroundColor: errorMessage == "" ? Colors.green : Colors.red,
            title: Center(
              child: Text(
                errorMessage == "" ? 
                'Check your inbox. An email has been sent to $email!' :
                errorMessage,
                style: const TextStyle(color: Colors.white)
              )
            ),
          );
        },
        barrierDismissible: true
      );
    }
    void doPasswordReset() async {
      String emailInput = textEditingController.text;
      try {
        await forgotPassword(email: emailInput);
        textEditingController.clear();
        showCheckEmailMessage("", emailInput);
      }
      on AuthException catch (e) {
        logger.severe(e.toString(), e);
        showCheckEmailMessage(e.message, "");
      }
    }
    
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  "Forgot password",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Text(
                  "Please enter your email to reset your password",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.grey
                  ),
                )
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  labelText: "Enter your email",
                  labelStyle: TextStyle(
                    color: Colors.black
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black
                    )
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    )
                  ),
                  contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0)
                )
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 25)),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ElevatedButton(
                      onPressed: () { 
                        doPasswordReset();
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: submitButtonColor
                      ),
                      child: Text(
                        "Reset Password",
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 18
                        ),
                      )
                    ),
                  ),
                )
              ],
            )
          ],
        )
      ),
    );
  }

}