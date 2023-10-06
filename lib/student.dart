import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Student {
  final String name;
  late DropdownMenuItem<Student> dropdownMenuItem;
  final ValueChanged<Student?>? delete;
  bool isClass = false;

  Student(this.name, this.delete) {
    add();
  }

  void add() {
    //check if name is class or student this depends on the name starting with a number or not
    isClass = name.startsWith(RegExp(r'[0-9]'));

    dropdownMenuItem = DropdownMenuItem(
      value: this,
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Icon(
                  isClass ? Icons.class_ : Icons.person,
                  size: 40,
                ),
                SizedBox(
                  width: 180,
                  child: Text(name),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            tooltip: 'Löschen',
            onPressed: () => delete!(this),
          ),
        ],
      ),
    );
  }

  void onSelect() {
    if (kDebugMode) {
      print('selected $name');
    }
  }

  void onDelete() {
    if (kDebugMode) {
      print('deleted $name');
    }
  }
}
