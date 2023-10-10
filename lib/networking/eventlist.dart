import 'dart:convert';
import 'dart:io';

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

    print(response);
  }
}

enum GradeLevel { S1, EF, Q1, Q2 }
