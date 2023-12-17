import 'package:flutter/material.dart';
import 'package:llgplan/category/category.dart';

class TimeTable extends PlanCategory {
  TimeTable() : super('Stundenplan', Icons.calendar_today);

  @override
  Future<Widget> build() async {
    return Center(
      child: Text('Stundenplan'),
    );
  }
}
