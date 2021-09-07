
import 'package:ensam_assisstant/DataList.dart';
import 'package:html/dom.dart';
import 'request.dart';

class PersonalData {

  static final String indexLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/index",
    markCurrentLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/noteselem-encours",
    moduleCurrentLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/notesmod-encours",
    markAbsLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/noteselem",
    moduleAbsLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/notesmod",
    yearLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/notesannee",
    semesterLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/notessem",
    absenceLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/absence/bilan",
    sanctionLink = "http://schoolapp.ensam-umi.ac.ma/schoolapp/student/absence/sanctions";

  Map personal = {};
  late DataList absence;
  late ModList modList;
  late Elements markCurrent, markAbs;
  late Module moduleCurrent,
      moduleAbs;
  late UnprocessableMarks semester,
      year;

  PersonalData._();

  static Future<PersonalData> create() async {
    var p = PersonalData._();
    await p.loadHtml();
    return p;
  }

  loadHtml() async {
    await loadInfo();
    //await loadAbsence();
    await loadMarksCurrent();
    await loadModuleCurrent();
    await loadMarksAbs();
    await loadModuleAbs();
    await loadSemester();
    await loadYear();
    await loadModList();
  }

  loadInfo() async {
    Document doc = await getHtml(indexLink);
    var div = doc.querySelector('[class="panel-body"]');
    personal['img']=div!.getElementsByTagName("img")[0].outerHtml.split('src="')[1].split('"')[0];
    var table = div.querySelectorAll('[class="table table-striped table-sm"]');
    for(var tab in table) {
      for (var t in tab.getElementsByTagName('tr')) {
        var tmp = t.getElementsByTagName('td');
        personal[tmp[0].innerHtml]=tmp[1].innerHtml;
      }
    }
    downloadFile("http://schoolapp.ensam-umi.ac.ma", personal['img'],"/img.jpeg");
  }

  loadAbsence() async{
    Document doc = await getHtml(absenceLink);
    var div = doc.querySelector('[class="card-body"]');
    var table = div!.querySelectorAll('[class="table table-striped table-sm"]');
    for(var tab in table) {
      for (var t in tab.getElementsByTagName('tr')) {
        var tmp = t.getElementsByTagName('td');
        personal[tmp[0].innerHtml] = tmp[1].innerHtml;
      }
    }
  }

  loadMarksCurrent() async{
    Document doc = await getHtml(markCurrentLink);
    markCurrent = new Elements.loadTable("markCurrent",doc.querySelector('table'), 0);
  }
  loadModuleCurrent() async{
    Document doc = await getHtml(moduleCurrentLink);
    moduleCurrent = new Module.loadTable("moduleCurrent",doc.querySelector('table'), 0);
  }
  loadMarksAbs() async{
    Document doc = await getHtml(markAbsLink);
    markAbs = new Elements.loadTable("markAbs",doc.querySelector('table'), 0);
  }
  loadModuleAbs() async{
    Document doc = await getHtml(moduleAbsLink);
    moduleAbs = new Module.loadTable("moduleAbs",doc.querySelector('table'), 0);
  }
  loadSemester() async{
    Document doc = await getHtml(semesterLink);
    var table = doc.querySelector('table');
    semester = new UnprocessableMarks.loadTable("semester",table, 2,);
  }
  loadYear() async{
    Document doc = await getHtml(yearLink);
    year = new UnprocessableMarks.loadTable("year",doc.querySelector('table'), 0);
  }

  loadModList() async{
    Document? doc = await postHTML("http://schoolapp.ensam-umi.ac.ma/schoolapp/plan-etudes-view/modules", {
      "niveau": personal["Niveau "],
      "filiere": personal["Filière "],
      "semestre": "S1"
    });
    var dataTable = doc!.querySelector('[class="table table-striped table-sm mb-1 display"]');
    modList = new ModList.loadDataTable("modList",dataTable);
    doc = await postHTML("http://schoolapp.ensam-umi.ac.ma/schoolapp/plan-etudes-view/modules", {
      "niveau": personal["Niveau "],
      "filiere": personal["Filière "],
      "semestre": "S2"
    });
    dataTable = doc!.querySelector('[class="table table-striped table-sm mb-1 display"]');
    modList.loadTable(dataTable);

  }
  
}

