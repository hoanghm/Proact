import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});
  
  @override
  SigninViewState createState() {
    return SigninViewState();
  }
}

class SigninViewState extends State<SigninView> {
  @override
  Widget build(Object context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
          "PROACT",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 54,
            fontWeight: FontWeight.w400,
            shadows: [
              const Shadow(
                offset: Offset(0, 4),
                blurRadius: 4,
                color: Color.fromRGBO(0, 0, 0, 0.25)
              )
            ]
          ),
        ),
          Container(height: 25),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
            onPressed: () => {

            }, 
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(89, 155, 67, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(15)
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: const Image(image: 
                    NetworkImage(
                      "https://s3-alpha-sig.figma.com/img/bb40/9287/197faf26fca9892c488cdf9b5cecefed?Expires=1719792000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=mvN2BQPnDXEpZOeGrbDQz-~wuRGUXyI4WNviBCfv8g6YSIH-uT1olhRbPWdoNHchGm6GgkC-WDdv1TiHSFZctasjLpeI9-E1rsoQ6XXNvYyhBLrQsCn7RupWMn7it0JmOxyN7u8XTg1igdlryGUxDGjwzDarb7iLnOiKH2KoDPdRe1~1Z2CPaMU71GE0d~en-n04D-qITbOcPs-GSCPZhDzgB5uHa6uxkSj1o4jXy3dZgNAZb~DEWVLi-huR7gc7LiNOxsbIEVYMqC6Jugj0jsxLFfQ5inRSVkOsIkhLzs56D9V66p6UF4x5D-2qlykqY4bYvJJ3EfIqysKuHRRDJA__"
                    ),
                    width: 30,
                    height: 30
                  )
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 9,
                  child: Text(
                    "Continue with Google",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,                  
                      ),
                    )
                  )
                ],
              )
            )  
          ),
          Container(height: 20),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: ElevatedButton(
            onPressed: () => {

            }, 
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromRGBO(89, 155, 67, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(15)
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: const Image(image: 
                    NetworkImage(
                      "https://s3-alpha-sig.figma.com/img/00d4/83ab/7221965d07009f7839c7619f383b2c7a?Expires=1719792000&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=Vp1~dW4tRCqzlJTO8up1XKkEj~haaA5pGY647XaN44SrWelKCGWTs3f-cz8~DV8iT0XdGo5YK-UCOELXfjp0qDiN1I5GOmYX7sbc-HTQFEj~HPpwbOlEtoRtP9p9aM-yXYuVLwPIHYR0IWHFNX7Uje19fnJKn1GOxCyRVF3qH2ayTrx8xmudsr7WWkkD46EYEXrdf2NeuFJ5i0uJqKrNLDuvd6DLYwaSnmDVHO6BN0kUZmcBW-NrHf5dDqs~c2mz3MXl5avMaL6UK-FZNcSZp1YwcHSwsX2xOHY5Cl2cATMJgT9f7EQbUs3Z92L-mL5X9xrCs0yGiUI5uNVfRalJWQ__"
                    ),
                    width: 35,
                    height: 35
                  )
                ),
                const Spacer(flex: 1),
                Expanded(
                  flex: 9,
                  child: Text(
                    "Continue with Email",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,                  
                      ),
                    )
                  )
                ],
              )
            )  
          ),
          Container(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () => {

                }, 
                child: Text(
                  "Sign in",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    color: const Color.fromRGBO(77, 127, 255, 1)
                  )
                ) 
              )
            ],
          )
        ],
      )
    );
  }
  
}