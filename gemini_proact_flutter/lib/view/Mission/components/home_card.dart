import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/components/home_card_label.dart';

class HomeCard extends StatefulWidget {
  final int currentEcoPoints;
  final int currentLevel;
  const HomeCard({super.key, required this.currentEcoPoints, required this.currentLevel});

  @override
  HomeCardState createState() {
    return HomeCardState();
  }
}

class HomeCardState extends State<HomeCard> {
  void setPlayerStatistics() async {

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setPlayerStatistics();
    });
  }

  @override
  Widget build (BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 25, right: 25),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: <Widget>[
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                          value: (widget.currentEcoPoints % 100) / 100,
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
                                  text: 'ECO',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 36
                                  )
                                )
                              ]
                            ),
                          ),
                          // const Icon(Icons.arrow_upward, size: 38, color: Colors.green)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 15)),
              HomeCardLabel(label: 'Level ${widget.currentLevel}'),
            ],
          )
        ],
      )
    );
  }
}