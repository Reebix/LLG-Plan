import 'package:flutter/widgets.dart';

abstract class PlanCategory {
  String name;
  IconData icon;

  PlanCategory(this.name, this.icon);

  Future<Widget> build();
}
