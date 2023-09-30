import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:llgplan/student.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LLGApp());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

class LLGApp extends StatelessWidget {
  const LLGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LLG Plan',
      theme: ThemeData.dark(),
      home: const LLGHomePage(),
    );
  }
}

class LLGHomePage extends StatefulWidget {
  const LLGHomePage({super.key});

  @override
  State<LLGHomePage> createState() => LLGHomePageState();
}

class LLGHomePageState extends State<LLGHomePage> {
  String _title = 'LLG Plan';
  Student? _currentStudent;

  final Icon addIcon = const Icon(Icons.add);
  final Icon personIcon = const Icon(Icons.person);
  final Icon classIcon = const Icon(Icons.class_);

  List<DropdownMenuItem<Student>> listItems = [];

  @override
  initState() {
    super.initState();
    loadStudents();
  }

  void loadStudents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? studentList = prefs.getStringList('students');
    setState(() {
      if (studentList == null) {
        studentList = [];
        prefs.setStringList('students', studentList!);
      }
      for (var student in studentList!) {
        addStudent(student, save: false);
      }
    });
  }

  void addStudent(name, {save = true}) async {
    var student = Student(name, (student) => deleteStudent(student!));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      listItems.add(student.dropdownMenuItem);

      _currentStudent = student;
      _title = student.name;

      if (!save) return;

      List<String>? studentList = prefs.getStringList('students');
      studentList?.add(name);
      prefs.setStringList('students', studentList!);
    });
  }

  Widget _buildConfirmDeletePopup(BuildContext context, Student student) {
    return AlertDialog(
      title: const Text('Schüler löschen'),
      content: const Text('Möchtest du den Schüler wirklich löschen?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(_context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(_context).pop();
            Navigator.of(_context).pop();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            List<String>? studentList = prefs.getStringList('students');
            studentList?.remove(student.name);
            prefs.setStringList('students', studentList!);

            setState(() {
              if (_currentStudent == student) {
                _currentStudent = null;
                _title = 'LLG Plan';
              }
              listItems.remove(student.dropdownMenuItem);
            });

            student.onDelete();
          },
          child: const Text('Löschen'),
        ),
      ],
    );
  }

  Widget _buildAddStudentPopup(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: const Text('Neuer Schüler'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(_context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(_context).pop();
            Navigator.of(_context).pop();
            addStudent(controller.text);
          },
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }

  void _addStudentPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) => _buildAddStudentPopup(context));
  }

  void deleteStudent(Student student) async {
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            _buildConfirmDeletePopup(context, student));
  }

  void selectStudent(Student student) {
    student.onSelect();
    setState(() {
      _currentStudent = student;
      _title = student.name;
    });
  }

  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
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
                    height: 0,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: _addStudentPopup,
                            child: const Text(
                              'Neuer Schüler oder Klasse',
                              textScaleFactor: 1.1,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...listItems,
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    selectStudent(value);
                  },
                ),
              ),
            ),
            const SingleChildScrollView(
              child: ListBody(children: [
                Text('Current Timetable'),
                Text('General Timetable'),
                Text('Exams'),
                Text('Teacher Information'),
                Text('Settings'),
                Text('About'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
