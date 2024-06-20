import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:logging/logging.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String appName = 'Proact';

void main() {
  // logging
  // TODO override log level w env variable
  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.message}\t@${record.loggerName}');
  });

  runApp(const Proact());
}

class Proact extends StatelessWidget {
  const Proact({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(
        title: '$appName Home Page'
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
    required this.title
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logger = Logger('HomePage');

  int _counter = 0;
  bool geminiIsInitialized = false;
  GenerativeModel? geminiModel;

  @override
  void initState() {
    super.initState();

    // init gemini client
    if (!geminiIsInitialized) {
      initGemini();
      geminiIsInitialized = true;
    }
  }

  void initGemini() {
    String googleGeminiApiKey;
    try {
      googleGeminiApiKey = Platform.environment['google_gemini_api_key'] ?? '';
    }
    on UnsupportedError {
      logger.warning('unable to fetch api key from device env variables; fetching from web server');
      googleGeminiApiKey = '';
    }
    
    if (googleGeminiApiKey == '') {
      logger.severe('error google gemini api key not found');
    }
    else {
      logger.fine('info google gemini api key = $googleGeminiApiKey');

      // init gemini api client
      geminiModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: googleGeminiApiKey);
      logger.info('gemini model api client initialized');
    }
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
            const Text(
              'You have clicked the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
