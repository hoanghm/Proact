import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  
  @override
  CameraPageState createState() {
    return CameraPageState();
  }
}

class CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  late CameraController controller;

  void initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    List<CameraDescription> descriptions = await availableCameras();
    setState(() {
      _cameras = descriptions;  
      controller = CameraController(_cameras[0], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              // Handle access errors here.
              break;
            default:
              // Handle other errors here.
              break;
          }
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      body: CameraPreview(controller),
    );
  }
}