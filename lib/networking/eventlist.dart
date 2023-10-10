import 'dart:convert';
import 'dart:io';

import 'package:html/parser.dart';

main() {
  EventList().fetch();
}

class EventList {
  getCookies(String url) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    httpClient.close();
    return response.cookies;
  }

  getPlanWithCookies(String url, List<Cookie> cookies) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.cookies.addAll(cookies);

    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  void fetch() async {
    //get cookies
    final cookies =
        await getCookies('https://termin.selbstlernportal.de/?ug=lev-llg');

    final response = await getPlanWithCookies(
        'https://selbstlernportal.de/html/termin/termin_klausur.php?ug=lev-llg&anzkw=25&',
        cookies);

    //parse response
    final document = parse(response);

    document.querySelectorAll('div.klausur').forEach((element) {
      // get date of current item
      final date = DateTime.parse(element.attributes['id']!.split('_').last);

      var nodeList = element.nodes;
      nodeList.removeWhere((element) => element.toString() == '<html hr>');

      for (int i = 0; i < nodeList.length; i++) {
        final text = nodeList[i].text;
        if (text != ' ') {
          events.add(Event(text!, GradeLevel.values[i], date));
        }
      }
    });

    lastUpdate = DateTime.now();
  }

  DateTime lastUpdate = DateTime.now();
  List<Event> events = [];

  Map toJson() => {
        'lastUpdate': lastUpdate,
        'events': events,
      };

  static EventList fromJson(Map json) {
    var eventList = EventList();
    eventList.lastUpdate = json['lastUpdate'];
    eventList.events = json['events'];
    return eventList;
  }
}

class Event {
  final String content;
  final GradeLevel grade;
  final DateTime date;

  Event(this.content, this.grade, this.date);

  @override
  String toString() {
    return 'Event{content: $content, grade: $grade, date: $date}';
  }

  Map toJson() => {
        'content': content,
        'grade': grade,
        'date': date,
      };

  Event fromJson(Map json) {
    return Event(json['content'], json['grade'], json['date']);
  }
}

enum GradeLevel { S1, EF, Q1, Q2 }
