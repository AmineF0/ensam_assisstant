import 'request.dart';

class ChangeHook {
  final String url = "https://changehook.herokuapp.com?op=compare&time=";
  Map? data;

  ChangeHook();

  getChangeHook({String savedTime = "1"}) async {
    var resp = await getJSON(url + savedTime);
    print(resp);
    this.data = {...resp};
    return resp;
  }

  setChangeHook(){

  }

  getServerUpdate() {
    return data?["time"] ?? "1";
  }

  getDecision() {
    print(data);
    return !(data?["upToDate"] ?? true);
  }
}
