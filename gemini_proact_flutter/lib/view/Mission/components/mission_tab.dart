import 'dart:ffi';

import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart' show MissionEntity;
import 'package:logging/logging.dart' show Logger;
import 'package:gemini_proact_flutter/model/backend/backend_controller.dart';

final logger = Logger((MissionTab).toString());
class MissionTab extends StatefulWidget {
  final MissionEntity mission;  
  final MissionEntity parentProject;
  final int index;
  final int parentIndex;
  final int ecoPoints;
  final int level;
  final void Function() onRefreshCallback;
  final void Function(int) stepCallback;
  final void Function(Map<String, dynamic>) callback;
  const MissionTab({super.key, required this.parentIndex, required this.onRefreshCallback, required this.parentProject, required this.mission, required this.index, required this.callback, required this.stepCallback, required this.ecoPoints, required this.level});

  @override
  MissionTabState createState() {
    return MissionTabState();
  }
}

class MissionTabState extends State<MissionTab> {
  bool isReloadingTab = false;
  @override
  Widget build (BuildContext context) {
    if (isReloadingTab) {
      return const SizedBox(
        width: 50,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            "Regenerate Mission",
            onPressed: () {
              setState(() {
                isReloadingTab = true;
              });
              regenerateMission(widget.mission.id, widget.parentProject.id).then((result) {
                widget.onRefreshCallback();
                setState(() {
                  isReloadingTab = false;
                });
              });
            },
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: TextButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MissionPage(mission: widget.mission, ecoPoints: widget.ecoPoints, level: widget.level, stepCallback: widget.stepCallback)) 
            );
            if (result == null) {
              return;
            }

            // Add points on successful mission completion
            widget.callback(result);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(bottom: 15),
            backgroundColor: Colors.grey.shade300, 
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)
            )
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                    ),
                    child: Text(
                      'Mission ${widget.index}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'ECO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18
                            )
                          ),
                          TextSpan(
                            text: ' ${widget.mission.ecoPoints}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18
                            )
                          )
                        ]
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Text(
                  widget.mission.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20 
                  ),
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}