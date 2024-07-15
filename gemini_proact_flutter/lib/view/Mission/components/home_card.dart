import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gemini_proact_flutter/view/Mission/components/home_card_label.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({super.key});

  @override
  HomeCardState createState() {
    return HomeCardState();
  }
}

class HomeCardState extends State<HomeCard> {
  @override
  Widget build (BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Column(
            children: <Widget>[
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  children: <Widget>[
                    const Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          value: 0.75,
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'CO',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 36
                                  )
                                ),
                                TextSpan(
                                  text: '2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 36,
                                    fontFeatures: [FontFeature.subscripts()]
                                  )
                                )
                              ]
                            ),
                          ),
                          const Icon(Icons.arrow_upward, size: 38, color: Colors.green)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Column(
            children: [
              HomeCardLabel(label: "50 Metric"),
              Padding(padding: EdgeInsets.only(top: 15)),
              HomeCardLabel(label: "Recruit"),
              Padding(padding: EdgeInsets.only(top: 15)),
              HomeCardLabel(label: "Title"),
            ],
          )
        ],
      )
    );
  }
}