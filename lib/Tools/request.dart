import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:cookie_jar/cookie_jar.dart';

import 'package:ensam_assisstant/main.dart';
import 'logging.dart';

String urlLogOut = "http://schoolapp.ensam-umi.ac.ma/schoolapp/logout";
String urlLog = "http://schoolapp.ensam-umi.ac.ma/schoolapp/login";
String urlIndex = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/index";

var dio = new Dio();
var cookieJar = new CookieJar();

remember(String email, String pass) async {
  data.session.set("email", email);
  data.session.set("pass", pass);
}

Future<bool> checkCred(String email, String pass, bool rememb) async {
  bool correct = await getInfo({'email': email, 'password': pass});
  if (rememb && correct) await remember(email, pass);
  return correct;
}

Future<bool> getInfo(var dataLoad) async {
  String url = "http://schoolapp.ensam-umi.ac.ma/schoolapp/login";

  dio.interceptors.add(CookieManager(cookieJar));
  dio.options.connectTimeout = 10000;
  print(dio.options.receiveTimeout);
  // second request with the cookie

  var form = await dio.get(url);
  var formDoc = parse(form.data);
  var token = formDoc
      .querySelector('[name="_csrf"]')
      ?.outerHtml
      .split("value=\"")[1]
      .split("\"")[0];
  if ((await cookieJar.loadForRequest(Uri.parse(url))).isEmpty) {
    var sess = form.headers.value("set-cookie")!.split(";")[0].split("=")[1];
    Cookie c = new Cookie("JSESSIONID", sess);
    cookieJar.saveFromResponse(Uri.parse(url), [c]);
  }
  dataLoad["_csrf"] = token;
  FormData formData = new FormData.fromMap(dataLoad);

  try {
    var log = await dio.post(
      url,
      data: formData,
      options:
          Options(
            followRedirects: false, validateStatus: (status) => true),
    );
    print(log);
    var fin = await dio.get("http://schoolapp.ensam-umi.ac.ma/schoolapp/index");
    return !fin.isRedirect!;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<Document> getHtml(url) async {
  var link = await dio.get(url);
  return parse(link.data);
}

Future<Document?> postHTML(url, dataLoad) async {
  var csrfDoc = await dio.get(url);
  try {
    dataLoad["_csrf"] = parse(csrfDoc.data)
        .querySelector('[name="_csrf"]')!
        .outerHtml
        .split("value=\"")[1]
        .split("\"")[0]; //get csrf
  } catch (e) {
    printErrLog("Network Error : Request.dart " + e.toString());
    return null;
  }
  FormData formData = new FormData.fromMap(dataLoad);
  try {
    var log = await dio.post(
      url,
      data: formData,
      options: Options(
          followRedirects: true,
          validateStatus: (status) {
            return status! < 400;
          }),
    );
    //debugPrint(parse(log.data).);
    return parse(log.data);
  } catch (e) {
    printErrLog("Network Error : Request.dart " + e.toString());
    return null;
  }
}

//TODO invistigate use
downloadFile(host, link, location) async {
  Response res =
      await dio.download(host + link, data.directory!.path + location);
}

forgetConnection() async {
  var log = await dio.get(urlLogOut);
}
