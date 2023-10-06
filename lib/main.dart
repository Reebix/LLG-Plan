import 'package:flutter/foundation.dart';
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
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

  var selectedCategory =
      (icon: Icons.home, name: 'Heutiger Plan', widget: Container());

  var allCategories = [
    (icon: Icons.home, name: 'Heutiger Plan', widget: Container()),
    (icon: Icons.calendar_today, name: 'Stundenplan', widget: Container()),
    (icon: Icons.event, name: 'Termine', widget: Container()),
    (icon: Icons.person, name: 'Lehrer Info', widget: Container()),
    (icon: Icons.settings, name: 'Einstellungen', widget: Container()),
    (icon: Icons.info, name: 'About', widget: Container()),
  ];

  String dsbUser = "153482";
  String dsbPw = "";
  String slpUser = "LLG";
  String slpPw = "";

  @override
  initState() {
    super.initState();
    loadStudents();

    setState(() {
      _getDsbPw().then((value) => dsbPw = value);
      _getSlpPw().then((value) => slpPw = value);
    });

    allCategories[4] = (
      icon: Icons.settings,
      name: 'Einstellungen',
      widget: Container(child: _buildConfigPage())
    );

    selectedCategory = allCategories[0];
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

  //<editor-fold desc="Build Stuff">
  Widget _buildConfigPage() {
    final TextEditingController dsbPwController =
        TextEditingController(text: dsbPw);
    final TextEditingController slpPwController =
        TextEditingController(text: slpPw);

    return SingleChildScrollView(
      child: ListBody(
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
            children: [
              SizedBox(
                width: 50,
              ),
              Text(
                'DSB Login Passwort:',
                textScaleFactor: 1.3,
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextField(
                  onSubmitted: _dsbPwSubmit,
                  controller: dsbPwController,
                  decoration: const InputDecoration(hintText: 'Passwort'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 50,
              ),
              Text(
                'SLP Login Passwort:',
                textScaleFactor: 1.3,
              ),
              SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextField(
                  onSubmitted: _slpPwSubmit,
                  controller: slpPwController,
                  decoration: const InputDecoration(hintText: 'Passwort'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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

  //</editor-fold>

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

  void _dsbPwSubmit(String value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('dsbPw', value);
      setState(() {
        dsbPw = value;
      });
      if (kDebugMode) print('saved dsbPw');
    });
  }

  void _slpPwSubmit(String value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('slpPw', value);
      setState(() {
        slpPw = value;
      });
      if (kDebugMode) print('saved slpPw');
    });
  }

  Future<String> _getDsbPw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dsbPw = prefs.getString('dsbPw');
    if (dsbPw != null) return dsbPw;
    return '';
  }

  Future<String> _getSlpPw() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? slpPw = prefs.getString('slpPw');
    if (slpPw != null) return slpPw;

    return '';
  }

  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Row(
          children: [
            Text(_title),
            // padding to right
            const Spacer(),
            Text(selectedCategory.name, textScaleFactor: 0.8),
            const SizedBox(width: 10),
            Icon(
              selectedCategory.icon,
              size: 20,
            ),
          ],
        ),
      ),
      //<editor-fold defaultstate="collapsed" desc="drawer">
      drawer: Drawer(
        width: 330,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
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
            SingleChildScrollView(
              child: ListBody(
                children: [
                  ...allCategories
                      .map((item) => ListTile(
                            selected: item == selectedCategory,
                            leading: Icon(item.icon),
                            title: Text(
                              //get second value of struct
                              item.name,
                              textScaleFactor: 1.4,
                            ),
                            onTap: () {
                              if (item.name == '') return;
                              setState(() {
                                selectedCategory = item;
                              });

                              Navigator.pop(context);
                            },
                          ))
                      .toList()
                ],
              ),
            ),
          ],
        ),
      ),
      //</editor-fold>

      body: kDebugMode ? _buildConfigPage() : selectedCategory.widget,
    );
  }
}
