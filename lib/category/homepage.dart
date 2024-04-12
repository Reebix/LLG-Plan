import 'package:flutter/material.dart';
import 'package:llgplan/category/category.dart';
import 'package:llgplan/main.dart';
import 'package:llgplan/timetable.dart';

class HomePage extends PlanCategory {
  HomePage() : super('Startseite', Icons.home);

  @override
  Future<Widget> build() async {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Heute"),
        TimeTable.instance!.currentDay.build(),
      ],
    ));
  }

  bool showNote = false;

  Widget _timetabelElement(Status status, {String note = ""}) {
    TextStyle style = TextStyle(
      decoration: status == Status.Canceled ? TextDecoration.lineThrough : null,
    );

    return ColoredBox(
      color: status.color,
      child: SizedBox(
        width: 150,
        height: 25,
        child: FilledButton(
          child: showNote
              ? Text(note)
              : Row(
                  children: [
                    Text('IF', style: style),
                    Text('X999', style: style),
                    Text('WIB', style: style),
                    Icon(note != "" ? Icons.textsms_outlined : null),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
          onPressed: () {
            if (note != "") {
              LLGHomePageState.instance!.setState(() {
                showNote = !showNote;
              });
            }
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
            textStyle: MaterialStateProperty.all(TextStyle(fontSize: 10)),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            shadowColor: MaterialStateProperty.all(Colors.transparent),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
      ),
    );
  }
}

enum Status {
  Normal,
  Replaced,
  Canceled;

  Color get color {
    switch (this) {
      case Status.Normal:
        return Colors.green;
      case Status.Replaced:
        return Colors.orange;
      case Status.Canceled:
        return Colors.red;
    }
  }
}
