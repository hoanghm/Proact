import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  OnboardingFormState createState() {
    return OnboardingFormState();
  }
} 

class OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: 
              Text(
              "PROACT",
              style: GoogleFonts.spaceGrotesk(
                textStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: Color.fromRGBO(0, 0, 0, 0.25)
                    )
                  ]
                )
              )
            ) 
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: 
              Text(
                "Please Answer some questions for more\npersonalized results",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300
                  )
                )
              ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("Full"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("Age"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("Occupation"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("Location"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("How often do you recycle?"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("What is your main form of transporation?"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
              border: const Border(
                bottom: BorderSide(width: 2, color: Color.fromRGBO(38, 164, 100, 1))
              ),
              borderRadius: BorderRadius.circular(100)
            ),
            child: TextFormField(
              cursorColor: Colors.green,
              decoration: const InputDecoration(
                label: Text("How often are you active?"),
                border: InputBorder.none
              ),
            )
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                )
              ]
            ),
            child: SizedBox(
              width: 275,
              height: 50,
              child: ElevatedButton(
                onPressed: () => {
                  // Navigator.push(
                  //   context, 
                  //   MaterialPageRoute(builder: (context) => const MainView())
                  // )
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(89, 155, 67, 1),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "Submit", 
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: const TextStyle(
                      fontSize: 25,
                    )
                  )
                )
              )       
            ),
          ),               
        ]
      ),
    );
  }
}