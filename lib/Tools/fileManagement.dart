import 'dart:convert';
import 'dart:io';

import 'package:ensam_assisstant/main.dart';
import 'package:path_provider/path_provider.dart';

loadFromFile(String identifier) async {
  Directory directory = data.directory ?? (await getApplicationDocumentsDirectory());
  File file = new File(directory.path + '/storage/' + identifier);
  try {
    return await file.readAsString(encoding: utf8);
  } catch (e) {
    return "";
  }
}

saveToFile(String text, String identifier) async {
  Directory directory = data.directory ?? (await getApplicationDocumentsDirectory());
  File file = new File(directory.path + '/storage/' + identifier);
  if (!await file.exists()) await file.create(recursive: true);
  await file.writeAsString(text);
}


String listToCSV(header, body) {
  String str = header.join('|');
  for (var e in body) {
    str += '\r\n' + e.join('|');
  }
  return str;
}

csvToList(text) {
  List<List> memBody = [];
  List<String> lines = text.split('\r\n');
  var it = lines.iterator;
  it.moveNext();
  it.current.split("|");
  while (it.moveNext()) {
    memBody.add(it.current.split('|'));
  }
  return memBody;
}
