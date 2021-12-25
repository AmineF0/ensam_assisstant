import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

import 'Data/RuntimeData.dart';
import 'Screens/SignInOne.dart';
import 'Screens/mainGUI.dart';
import 'Tools/backgroundFetch.dart';
import 'Tools/notifications.dart';
import 'Tools/getAllMods.dart';

//TODO: setting page
//TODO: fix notif
//TODO: theme support

RuntimeData data = new RuntimeData();

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Widget> loadFromFuture() async {
    await data.loadDirectory();
    var rs = await data.loadSession();
    printActivityLog("[" + DateTime.now().toString() + "] " + " : app start");
    if (rs) {
      await data.load();
      if (data.session.get(UserData.backgroundFetch)) initBgFetch();
      return Future.value(new Home());
    } else
      return Future.value(new SignIn());
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      navigateAfterFuture: loadFromFuture(),
      title: new Text('Welcome In SplashScreen'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      loaderColor: Color(0xff0065a3),
    );
  }
}

class SignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SignInOne());
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => MenuProvider(),
        child: HomeScreen(),
      ),
      //debugShowCheckedModeBanner: false,
    );
  }
}
