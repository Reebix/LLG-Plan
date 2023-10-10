import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

main() {
  SubstitutionPlanFetcher.fetch();
}

class SubstitutionPlanFetcher {
  static String dsbUser = "153482";
  static String dsbPw = "llg-schueler";

  static void fetch() async {
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

    var paramsByteString = jsonEncode(params);
    var paramsCompressed = base64.encode(utf8.encode(paramsByteString));

    String jsonData = jsonEncode({
      "req": {"Data": paramsCompressed, "DataType": 1}
    });

    var response = http
        .post(Uri.parse("https://app.dsbcontrol.de/JsonHandler.ashx/GetData"),
            headers: {
              "Content-Type": "application/json;charset=utf-8",
              "Accept-Encoding": "gzip, deflate",
              "User-Agent":
                  "Dalvik/2.1.0 (Linux; U; Android 8.1.0; Nexus 4 Build/OPM7.181205.001)",
            },
            body: jsonData,
            encoding: Encoding.getByName("gzip"))
        .then((value) => {
              print(value.body),
              print(value.statusCode),
            });
  }
}

class SubstitutionPlan {
  final String class_;
  final int lesson;
  final String newTeacher;
  final String newSubject;
  final String oldSubject;
  String comment;
  final String type;
  final String room;

  SubstitutionPlan(this.class_, this.lesson, this.newTeacher, this.newSubject,
      this.oldSubject, this.comment, this.type, this.room);

  @override
  String toString() {
    return 'SubstitutionPlan{class_: $class_, lesson: $lesson, newTeacher: $newTeacher, newSubject: $newSubject, oldSubject: $oldSubject, comment: $comment, type: $type, room: $room}';
  }
}
