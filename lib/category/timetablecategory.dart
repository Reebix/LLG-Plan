import 'package:flutter/material.dart';
import 'package:llgplan/category/category.dart';
import 'package:llgplan/timetable.dart';

class TimeTableCategory extends PlanCategory {
  TimeTableCategory() : super('Stundenplan', Icons.calendar_today);

  @override
  Future<Widget> build() async {
    TimeTable timeTable = TimeTable(TableStudent("test", "test", "10b"));
    await timeTable.fetch();
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [],
      ),
      body: Center(
        child: timeTable.build(),
      ),
    );
  }

  Widget buildAddStudentPopup(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return AlertDialog(
      title: const Text('Neuer Schüler'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) =>
                    buildSelectStudentPopup(context, controller.text));
          },
          child: const Text('Suchen'),
        ),
      ],
    );
  }

  Future<Widget> fetchPossibleStudents(
      String name, BuildContext context) async {
    List<Widget> list = [];
    list.add(TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          print('test' + name);
        },
        child: Text('test' + name)));

    return Column(
      children: list,
    );
  }

  Widget buildSelectStudentPopup(BuildContext context, String name) {
    return AlertDialog(
      title: const Text('Schüler auswählen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder(
              future: fetchPossibleStudents(name, context),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data as Widget;
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}
