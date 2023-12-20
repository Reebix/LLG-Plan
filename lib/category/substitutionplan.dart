import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:llgplan/category/category.dart';
import 'package:uuid/uuid.dart';

main() {
  SubstitutionPlan().fetch();
}

class SubstitutionPlan extends PlanCategory {
  String dsbUser = "153482";
  String dsbPw = "llg-schueler";

  SubstitutionPlan() : super('Vertretungsplan', Icons.school);

  Uint8List gunzipDecode(List<int> data) {
    final byteStream = BytesBuilder();
    final gzipDecoder = GZipCodec();
    byteStream.add(gzipDecoder.decode(data));
    return byteStream.toBytes();
  }

  Uint8List gzipEncode(List<int> data) {
    final byteStream = BytesBuilder();
    final gzipEncoder = GZipCodec();
    byteStream.add(gzipEncoder.encode(data));
    return byteStream.toBytes();
  }

  Future<String> apiRequest(String url, String data) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('accept-encoding', 'gzip, deflate');
    request.add(utf8.encode(data));
    HttpClientResponse response = await request.close();

    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  Future<List<SubstitutionDay>> fetch() async {
    var params = Map<String, String>();

    var currentTime = DateTime.now().toUtc().toIso8601String();

    params["UserId"] = dsbUser;
    params["UserPw"] = dsbPw;
    params["AppVersion"] = "2.5.9";
    params["Language"] = "de";
    params["OsVersion"] = "27.8.1.0";
    params["AppId"] = Uuid().v4();
    params["Device"] = "Nexus 4";
    params["BundleId"] = "de.heinekingmedia.dsbmobile";
    params["Data"] = currentTime;
    params["LastUpdate"] = currentTime;

    final paramsJson = jsonEncode(params);
    final paramsGzip = gzipEncode(utf8.encode(paramsJson));
    final paramsBase64 = base64.encode(paramsGzip);

    final finalData = json.encode({
      'req': {
        'Data': paramsBase64,
        'DataType': 1,
      },
    });

    final response = await apiRequest(
        'https://app.dsbcontrol.de/JsonHandler.ashx/GetData', finalData);

    final decodedResponse = json.decode(response);
    final decodedData = decodedResponse['d'];
    final decodedDataGzip = base64.decode(decodedData);
    final decodedDataJson = utf8.decode(gunzipDecode(decodedDataGzip));
    final decodedDataMap = json.decode(decodedDataJson);

    final substitutionPlanUrl = decodedDataMap['ResultMenuItems'][0]['Childs']
        [1]['Root']['Childs'][0]['Childs'][0]['Detail'];

    final substitutionPlanResponse =
        await http.get(Uri.parse(substitutionPlanUrl));

    var substitutionPlanDocument = substitutionPlanResponse.body;
    final parsed = parse(substitutionPlanDocument);

    parsed.querySelectorAll('div.mon_title').forEach((element) {
      days.add(SubstitutionDay.createFromFormatted(element.text));
    });

    var dayList = parsed.querySelectorAll('table.mon_list');

    for (var i = 0; i < days.length; i++) {
      var element = dayList[i];

      element.querySelectorAll('tr').forEach((element) {
        // print(element.innerHtml);
        if (element.firstChild?.text == 'Klasse' ||
            element.children.length == 1 ||
            element.firstChild?.text == ' ') {
          return;
        }
        final children = element.children;

        var shouldSkip = children[0].text.contains('Klausur') ||
            children[0].text.contains('Joker');
        final class_ = children[0].text;
        final lessons = children[1].text.split(' - ').map((e) {
          final parsed = int.tryParse(e);
          shouldSkip = shouldSkip ? shouldSkip : parsed == null;
          return parsed == null ? 0 : parsed;
        }).toList();
        if (shouldSkip) {
          return;
        }
        final newTeacher = children[2].text;
        final newSubject = children[3].text;
        final oldSubject = children[4].text;
        final comment = children[5].text;
        final type = children[6].text;
        final room = children[7].text;

        days[i].substitutions.add(Substitution(class_, lessons, newTeacher,
            newSubject, oldSubject, comment, type, room));
      });
    }
    lastUpdate = DateTime.now();
    return days;
  }

  var lastUpdate = DateTime.now();
  List<SubstitutionDay> days = [];

  Map toJson() => {
        'lastUpdate': lastUpdate,
        'days': days,
      };

  static SubstitutionPlan fromJson(Map json) {
    var fetcher = SubstitutionPlan();
    fetcher.lastUpdate = json['lastUpdate'];
    fetcher.days = json['days'];
    return fetcher;
  }

  @override
  Future<Widget> build() async {
    await fetch();

    //TODO: remove after testing
    days[0].substitutions.add(Substitution('5a', [1], 'Herr Müller', 'Mathe',
        'Deutsch', 'Entfall', 'Entfall', ''));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Stand: '),
            Text(
              DateFormat('dd.MM – kk:mm').format(lastUpdate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              return ExpansionTile(
                title: Text(
                  DateFormat('dd.MM').format(days[index].date),
                ),
                children: days[index].substitutions.map((e) {
                  return ListTile(
                    title: Text(e.class_ + ' ' + e.newTeacher),
                    subtitle: Text(
                        e.lessons.join(', ') + ' ' + e.comment + ' ' + e.type),
                    trailing: Text(e.oldSubject + ' --> ' + e.newSubject),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SubstitutionDay {
  //fromat: 29.9.2023 Freitag, Woche B

  final DateTime date;
  final List<Substitution> substitutions;

  SubstitutionDay(this.date, this.substitutions);

  static createFromFormatted(String formatted) {
    final splitted = formatted.split(' ')[0].split('.');
    final date = DateTime.parse(
        '${splitted[2]}-${splitted[1].padLeft(2, '0')}-${splitted[0].padLeft(2, '0')}');
    final substitutions = List<Substitution>.empty(growable: true);
    return SubstitutionDay(date, substitutions);
  }

  static createFromJson(Map json) {
    final date = json['date'];
    final substitutions = json['substitutions'];
    return SubstitutionDay(date, substitutions);
  }

  @override
  String toString() {
    return 'SubstitutionDay{date: $date, substitutions: $substitutions}';
  }

  Map toJson() => {
        'date': date,
        'substitutions': substitutions,
      };

  static SubstitutionDay fromJson(Map json) {
    return SubstitutionDay(
      json['date'],
      json['substitutions'],
    );
  }
}

class Substitution {
  final String class_;
  List<int> lessons;
  final String newTeacher;
  final String newSubject;
  final String oldSubject;
  final String comment;
  final String type;
  final String room;

  Substitution(this.class_, this.lessons, this.newTeacher, this.newSubject,
      this.oldSubject, this.comment, this.type, this.room) {
    if (lessons.length != 1)
      for (var i = lessons[0] + 1; i < lessons[1]; i++) {
        lessons.add(i);
      }

    this.lessons = lessons;
  }

  @override
  String toString() {
    return 'SubstitutionPlan{class_: $class_, lesson: $lessons, newTeacher: $newTeacher, newSubject: $newSubject, oldSubject: $oldSubject, comment: $comment, type: $type, room: $room}';
  }

  Map toJson() => {
        'class_': class_,
        'lessons': lessons,
        'newTeacher': newTeacher,
        'newSubject': newSubject,
        'oldSubject': oldSubject,
        'comment': comment,
        'type': type,
        'room': room,
      };

  static Substitution fromJson(Map json) {
    return Substitution(
      json['class_'],
      json['lessons'],
      json['newTeacher'],
      json['newSubject'],
      json['oldSubject'],
      json['comment'],
      json['type'],
      json['room'],
    );
  }
}
