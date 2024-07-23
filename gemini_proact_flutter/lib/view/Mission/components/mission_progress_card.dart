import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissionProgressCard extends StatefulWidget {
  final int currStep;
  final int totalSteps;
  final int rewardAmount;
  final String description;
  const MissionProgressCard({super.key, required this.currStep, required this.totalSteps, required this.rewardAmount, required this.description});

  @override
  MissionProgressCardState createState() {
    return MissionProgressCardState();
  }
}

class MissionProgressCardState extends State<MissionProgressCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.only(top: 25)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
            ),     
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: LinearProgressIndicator(
                    value: (widget.currStep / widget.totalSteps),
                    minHeight: 20,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff00ff00)),
                    backgroundColor: const Color(0xffD6D6D6),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 5)),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${widget.currStep}/${widget.totalSteps}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      '+ ${widget.rewardAmount}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24
                      ),
                    ),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'CO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24
                            )
                          ),
                          TextSpan(
                            text: '2',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFeatures: [FontFeature.subscripts()]
                            )
                          )
                        ]
                      ),
                    )
                  ],
                )
              ),
              Flexible(
                flex: 2,
                child: Text(
                  widget.description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16
                  ),
                )
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 15)),
        ],
      ),
    );
  }
}