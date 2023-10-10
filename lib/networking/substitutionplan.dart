import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

    print(decodedDataMap);
  }

  static Uint8List gunzipDecode(List<int> data) {
    final byteStream = BytesBuilder();
    final gzipDecoder = GZipCodec();
    byteStream.add(gzipDecoder.decode(data));
    return byteStream.toBytes();
  }

  static Uint8List gzipEncode(List<int> data) {
    final byteStream = BytesBuilder();
    final gzipEncoder = GZipCodec();
    byteStream.add(gzipEncoder.encode(data));
    return byteStream.toBytes();
  }

  static Future<String> apiRequest(String url, String data) async {
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
