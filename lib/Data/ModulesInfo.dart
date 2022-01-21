import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:html/parser.dart';

/*class ModList {
  String identifier = "Def";
  Map modules = {};

  loadTable(dataTable) {
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

      modules[tmpMap["CodeMod"]] = tmpMap;
    }
  }

  ModList(identifier) {
    this.identifier = identifier;
  }

  ModList.loadDataTable(identifier, dataTable) {
    this.identifier = identifier;
    loadTable(dataTable);
  }

  findElem(String code) {
    String mod = code.substring(0, code.lastIndexOf("_"));
    if (modules.containsKey(mod)) return modules[mod]["elem"][code];
    return {"Intitule": mod};
  }

  findMod(String mod) {
    if (modules.containsKey(mod)) return modules[mod];
    return {"Intitule": mod};
  }
}*/

class ModList {
  Map modules = {};

  loadmods() async {
    String modText = await rootBundle.loadString('Assets/modsList.json');
    modules = json.decode(modText)[0];
  }

  findElem(String code) {
    String mod = code.substring(0, code.lastIndexOf("_"));
    if (modules.containsKey(mod)) return modules[mod]["elem"][code];
    return {"Intitule": mod};
  }

  findParentMod(String code) {
    String mod = code.substring(0, code.lastIndexOf("_"));
    if (modules.containsKey(mod))
      return modules[mod];
    else if (modules.containsKey(code)) return modules[code];
    return {"Intitule": mod};
  }

  findMod(String mod) {
    if (modules.containsKey(mod)) return modules[mod];
    return {"Intitule": mod};
  }
}
