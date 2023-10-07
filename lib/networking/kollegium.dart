// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:llgplan/main.dart';

class KollegiumFetcher {
  static List<Teacher> teachers = [];

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
      KollegiumFetcher.teachers = teachers;
    });
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
}

/*
</tr>
            <tr class="row_172 even">
                    <td class="body col_0 col_first">Jan Marco</td>
                    <td class="body col_1">Walter</td>
                    <td class="body col_2">WALT</td>
                                            <td class="body col_3 col_last"><a href="informationen-4.html?show=377"><img src="assets/contao/images/info.svg" width="16" height="16" alt=""></a></td>
                            </tr>
 */

/*
<table class="single_record">
  <tbody>
          <tr class="row_0 row_first even">
        <td class="label">Vorname</td>
        <td class="value">Simone</td>
      </tr>
          <tr class="row_1 odd">
        <td class="label">Nachname</td>
        <td class="value">Zimmermann</td>
      </tr>
          <tr class="row_2 even">
        <td class="label">E-Mail-Adresse</td>
        <td class="value"><a href="mailto:zimmermann@landrat-lucas.org">zimmermann@landrat-lucas.org</a></td>
      </tr>
          <tr class="row_3 row_last odd">
        <td class="label">Kürzel</td>
        <td class="value">ZIM</td>
      </tr>
      </tbody>
  </table>
 */
