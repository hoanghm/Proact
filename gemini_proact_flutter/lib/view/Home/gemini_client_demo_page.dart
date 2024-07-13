import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/gemini_client.dart';
import 'package:gemini_proact_flutter/model/internal_client.dart';
import 'package:logging/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Old home page used for app scaffold and gemini client troubleshooting.
class HomePage extends StatefulWidget {
  final String title = 'Home Page';
  final User user = FirebaseAuth.instance.currentUser!;

  HomePage({
    super.key
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = Logger((HomePage).toString());
  int _counter = 0;
  final String _prompt = 'give me a summary of the first half of cien años de soledad in 2 english paragraphs';
  String? _response;

  @override
  void initState() {
    super.initState();

    // Confirm internal server connectivity
    try {
      InternalClient.getPing();
      logger.info('internal server connection confirmed');
    }
    catch (err) {
      logger.severe('failed to connect to internal server. $err');
    }

    // Init gemini client
    GeminiClient.init();
  }

  // sign user out
  void signUserOut()  {
    FirebaseAuth.instance.signOut();
  }
  
  void onButton() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });

    GeminiClient.promptGemini(prompt: _prompt)
    .then((response) {
      setState(() {
        _response = response ?? '<no response or error>';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))]
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Button click counter:'),
            Text('$_counter'),
            const Text('Example gemini prompt:'),
            Text(_prompt),
            const Text('Gemini response:'),
            Text(_response ?? '<no response>')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onButton,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
