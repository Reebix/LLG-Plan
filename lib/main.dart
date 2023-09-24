import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLG Plan',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  //Icons.class_ for class

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  String _title = 'LLG Plan';
  List<Widget> _testStudents = [];

  Icon addIcon = const Icon(Icons.add);

  void _addStudent() {
    var box = const SizedBox();
    box = SizedBox(
      height: 50,
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text(
          'Timon David Richter',
          textScaleFactor: 1.1,
        ),
        onLongPress: () => setState(() => _testStudents.remove(box)),
        onTap: () => setState(() => _title = 'Timon David Richter'),
      ),
    );
    setState(() {
      _testStudents.add(
        box,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
    for (int i = 0; i < 10; i++) {
      _testStudents.add(
        SizedBox(
          height: 50,
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Timon David Richter',
              textScaleFactor: 1.1,
            ),
          ),
        ),
      );
    }

   */

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(_title),
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Schüler',
                      textAlign: TextAlign.left,
                      textScaleFactor: 1.5,
                    ),
                    IconButton(
                      icon: addIcon,
                      onPressed: _addStudent,
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: ListBody(
                children: _testStudents,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'No: ',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => setState(() => _counter = _counter - 1),
                  child: const Text('Subtract'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _counter = 0),
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => _testStudents.clear()),
                  child: const Text('Reset List'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
