import 'package:flutter/material.dart';
import 'package:llgplan/category/category.dart';

class HomePage extends PlanCategory {
  HomePage() : super('Startseite', Icons.home);

  @override
  Future<Widget> build() async {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Willkommen im '),
        Text(
          'Selbstlernportal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    ));
  }
}
