// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:llgplan/main.dart';

class KollegiumFetcher {
  List<Teacher> teachers = [];

  void fetch() async {
    List<Teacher> teachers = [];

    final response = await http
        .get(Uri.parse('https://www.landrat-lucas.org/kollegium.html'));
    if (response.statusCode != 200) {
      print('Error: ${response.statusCode}');
      return;
    }
    final document = parse(response.body);

    document
        .querySelector('table.all_records')
        ?.querySelector('tbody')
        ?.children
        .forEach((element) {
      Teacher teacher = Teacher(
        element.children[0].text,
        element.children[1].text,
        element.children[2].text,
        int.parse(element.children[3].children[0].attributes['href']!
            .split('show=')[1]),
      );

      teachers.add(teacher);
    });

    if (kDebugMode) {
      print('loaded ${teachers.length} teachers');
    }

    LLGHomePageState.instance!.setState(() {
      teachers = teachers;
    });
  }

  Map toJson() => {
        'teachers': teachers,
      };

  static KollegiumFetcher fromJson(Map json) {
    KollegiumFetcher fetcher = KollegiumFetcher();
    fetcher.teachers = json['teachers'];
    return fetcher;
  }
}

class Teacher {
  final String vorname;
  final String name;
  final String kuerzel;
  final int websiteId;

  String get fullName => '$vorname $name';

  String? email = 'not found';

  String get emailLink => 'mailto:$email';

  Widget? get emailLinkText => email == 'not found'
      ? Text('Tipp zum Anzeigen der E-Mail-Adresse: Tippe auf den Namen.')
      : Row(
          children: [
            Icon(Icons.email),
            SizedBox(width: 10),
            Text(email!),
            Spacer(),
            Icon(Icons.copy),
          ],
        );

  Teacher(this.vorname, this.name, this.kuerzel, this.websiteId);

  @override
  String toString() {
    return '$vorname $name ($kuerzel) $websiteId';
  }

  void getEmail() async {
    final response = await http.get(Uri.parse(
        'https://www.landrat-lucas.org/kollegium.html?show=$websiteId'));

    if (response.statusCode != 200) {
      print('Error: ${response.statusCode}');
      return;
    }
    final document = parse(response.body);

    email = document
        .querySelector('table.single_record')
        ?.querySelector('tbody')
        ?.children[2]
        .children[1]
        .innerHtml
        .split('>')[1]
        .split('<')[0];

    LLGHomePageState.instance!.setState(() {});

    if (kDebugMode) {
      print(email);
    }
  }

  ListTile get widget => ListTile(
        leading: Text(kuerzel),
        title: Text(fullName),
        onTap: () => getEmail(),
        subtitle: emailLinkText,
      );

  Map toJson() => {
        'vorname': vorname,
        'name': name,
        'kuerzel': kuerzel,
        'websiteId': websiteId,
      };

  static Teacher fromJson(Map json) {
    Teacher teacher = Teacher(
        json['vorname'], json['name'], json['kuerzel'], json['websiteId']);
    return teacher;
  }
}
