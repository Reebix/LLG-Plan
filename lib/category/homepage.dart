import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:llgplan/category/category.dart';
import 'package:llgplan/main.dart';
import 'package:llgplan/timetable.dart';

class HomePage extends PlanCategory {
  HomePage() : super('Startseite', Icons.home);

  @override
  Future<Widget> build() async {
    var currentWeekDay = DateTime.now().copyWith(
        microsecond: 0, millisecond: 0, second: 0, minute: 0, hour: 0);

    //get calender week
    int dayOfYear = int.parse(DateFormat("D").format(currentWeekDay));
    var week = ((dayOfYear - currentWeekDay.weekday + 10) / 7).floor();
    int weekType = week % 2;

    var currentDay =
        TimeTable.instance!.tables[weekType][DateTime.now().weekday - 1];

    print(currentDay);

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Heute"),
        currentDay.build(),
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
            padding: WidgetStateProperty.all(EdgeInsets.all(0)),
            textStyle: WidgetStateProperty.all(TextStyle(fontSize: 10)),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
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
