import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:llgplan/student.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'student.dart';

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
  Student? _currentStudent;

  final Icon addIcon = const Icon(Icons.add);
  final Icon personIcon = const Icon(Icons.person);
  final Icon classIcon = const Icon(Icons.class_);

  List<DropdownMenuItem<Student>> listItems = [];
  SharedPreferences? storage;

  //constructor
  _MyHomePageState() {
    () async => storage = await SharedPreferences.getInstance();

    listItems = [];
    listItems.add(DropdownMenuItem(
      value: null,
      onTap: () => addStudent('Temp placeholder'),
      child: const Row(
        children: [
          Icon(
            Icons.add,
            size: 40,
          ),
          Text(
            'Neuer Schüler',
            textScaleFactor: 1.1,
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    ));

    var studentList = storage?.getStringList('students');
    if (studentList == null) {
      //TODO: fix saving
      print('no students found');
      () async => await storage?.setStringList('students', []);
      studentList = [];
    }

    for (var student in studentList) {
      print(student);
      //addStudent(student, save: false);
    }
  }

  void addStudent(name, {save = true}) {
    var student = Student(name);

    setState(() {
      listItems.add(student.dropdownMenuItem);

      _currentStudent = student;
      _title = student.name;

      if (!save) return;

      /*
      List<String>? studentList = storage?.getStringList('students');
      studentList?.add(name);
      storage?.setStringList('students', studentList!);

      for (var student in studentList!) {
        print(student);
      }
      */

          });

  }

  void selectStudent(Student student) {
    student.select();
    setState(() {
      _title = student.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(_title),
      ),
      drawer: Drawer(
        width: 330,
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
                child: DropdownButton(
                  value: _currentStudent,
                  iconSize: 30,
                  hint: const Text('Wähle einen Schüler oder Klasse aus'),
                  underline: Container(
                    height: 2,
                    color: Colors.green,
                  ),
                  items: listItems,
                  onChanged: (value) {
                    if (value == null || value.name == 'add') return;
                    setState(() {
                      _currentStudent = value;
                      _title = value.name;
                    });
                  },
                ),
              ),
            ),
            const SingleChildScrollView(
              child: ListBody(children: [
                Text('Current Timetable'),
                Text('General Timetable'),
                Text('Exams'),
                Text('Settings'),
                Text('Teacher Information'),
                Text('About'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
