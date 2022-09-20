import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:html/dom.dart';
import 'package:path_provider/path_provider.dart';
import '../Tools/request.dart';

Map<String, dynamic> modules = {};
List<List<String>> combinations = [[], [], []];
const String fileName = "modList";

getCombinations() async {
  Document doc = await getHtml(
      "http://schoolapp.ensam-umi.ac.ma/schoolapp/plan-etudes-view/modules");

  var nv = doc.querySelector('[id="niveau"]')!;
  var nvOptions = nv.getElementsByTagName("option");
  nvOptions.forEach((element) {
    combinations[0].add(filtOpt(element.outerHtml));
  });

  var fil = doc.querySelector('[id="filiere"]')!;
  var nvFil = fil.getElementsByTagName("option");
  nvFil.forEach((element) {
    combinations[1].add(filtOpt(element.outerHtml));
  });

  var sem = doc.querySelector('[id="semestre"]')!;
  var nvSem = sem.getElementsByTagName("option");
  nvSem.forEach((element) {
    combinations[2].add(filtOpt(element.outerHtml));
  });
}

loadModList() async {
  await getCombinations();

  for (String nv in combinations[0]) {
    for (String fil in combinations[1]) {
      for (String sem in combinations[2]) {
        print("nv:$nv fil:$fil sem:$sem");
        Document? doc = await postHTML(
            "http://schoolapp.ensam-umi.ac.ma/schoolapp/plan-etudes-view/modules",
            {"niveau": nv, "filiere": fil, "semestre": sem});
        var dataTable = doc!.querySelector(
            '[class="table table-striped table-sm mb-1 display"]');
        loadTable(dataTable, nv, fil, sem);
      }
    }
  }
  await saveMapToFile();
  debugPrint(modules.toString());

}

loadTable(dataTable, nv, fil, sem) {
  List modHeader = ["i"];
  var modulesList = dataTable.querySelectorAll('[class="clickable"]');
  var head = dataTable.querySelector('thead');
  for (var t in head.getElementsByTagName('tr')) {
    var tmp = t.getElementsByTagName('th');
    for (var elem in tmp) {
      modHeader.add(elem.innerHtml);
    }
  }
  for (var mod in modulesList) {
    var tmp = mod.getElementsByTagName('td');
    Map tmpMap = {};
    for (int n = 0; n < tmp.length; n++) {
      tmpMap[modHeader[n]] = tmp[n].innerHtml;
    }

    //check elem
    var elemList = dataTable
        .querySelector('[class="collapse ' + tmpMap["CodeMod"] + '"]')
        .querySelector('[class="table table-sm mb-1 display"]');
    List elemHeader = [];
    var elemHead = elemList.querySelector('thead');
    for (var t in elemHead.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('th');
      for (var elem in tmp) {
        elemHeader.add(elem.innerHtml);
      }
    }
    var elemBody = elemList.querySelector('tbody');
    var tmpElem = {};
    for (var elem in elemBody.getElementsByTagName('tr')) {
      var tmp = elem.getElementsByTagName('td');
      Map tmpMapElem = {};
      for (int n = 0; n < tmp.length; n++) {
        tmpMapElem[elemHeader[n]] = tmp[n].innerHtml;
      }
      tmpElem[tmpMapElem["CodeElem"]] = tmpMapElem;
    }
    tmpMap["elem"] = tmpElem;
    //end

    tmpMap.remove("i");
    if (tmpMap.length == 0) return;

    tmpMap["trueNv"] = nv;
    tmpMap["trueFil"] = fil;
    tmpMap["trueSem"] = sem;
    
    modules[tmpMap["CodeMod"]] = tmpMap;
  }
}

String filtOpt(String option) {
  return option.split('value="')[1].split('"')[0];
}

saveMapToFile() async {
  await saveToExternalFile(jsonEncode([modules]), fileName);
}

saveToExternalFile(String jsonEncode, String fileName) async {
  Directory? dir = await getExternalStorageDirectory();
  File file = new File(dir!.path + '/tmp/modsList.json');
  print(file.path);
  try {
    if (!await file.exists()) await file.create(recursive: true);
    await file.writeAsString(jsonEncode);
  } catch (e) {
    print(e);
  }
}
