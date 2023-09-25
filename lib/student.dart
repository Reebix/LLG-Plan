import 'package:flutter/material.dart';

class Student {
  final String name;
  late DropdownMenuItem<Student> dropdownMenuItem;
  bool isClass = false;

  Student(this.name) {
    add();
  }

  void add() {
    //check if name is class or student this depends on the name starting with a number or not
    isClass = name.startsWith(RegExp(r'[0-9]'));

    dropdownMenuItem = DropdownMenuItem(
      value: this,
      child: Row(
        children: [
          Icon(
            isClass ? Icons.class_ : Icons.person,
            size: 40,
          ),
          Text(name),
        ],
      ),
    );
  }

  void select() {
    print('selected');
  }
}
