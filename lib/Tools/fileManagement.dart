import 'dart:convert';
import 'dart:io';

import 'package:ensam_assisstant/Data/RuntimeData.dart';

SaveToFile(String text, String identifier) async {
  File file = new File(RuntimeData.directory.path + '/storage/' + identifier);
  if (!await file.exists()) await file.create(recursive: true);
  await file.writeAsString(text);
}

String ListToCSV(header, body) {
  String str = header.join('|');
  for (var e in body) {
    str += '\r\n' + e.join('|');
  }
  return str;
}

CsvToList(text) {
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

loadFromFile(String identifier) async {
  File file = new File(RuntimeData.directory.path + '/storage/' + identifier);
  try {
    return await file.readAsString(encoding: utf8);
  } catch (e) {
    return "";
  }
}
