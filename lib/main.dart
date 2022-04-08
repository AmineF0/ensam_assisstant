import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splashscreen/splashscreen.dart';

import 'Data/RuntimeData.dart';
import 'Screens/SignInOne.dart';
import 'Screens/mainGUI.dart';
import 'Tools/backgroundFetch.dart';

//TODO: setting page
//TODO: fix notif
//TODO: theme support

RuntimeData data = new RuntimeData();

const kBackgroundColor = Color(0xFFF8F8F8);
const kActiveIconColor = Color(0xFFE68342);
const kTextColor = Color(0xFF222B45);
const kBlueLightColor = Color(0xFFC7B8F5);
const kBlueColor = Color(0xFF817DC0);
const kShadowColor = Color.fromARGB(255, 149, 152, 165);
Color cPrimary = Color(0xff6699cc);
Color cgPrimary = Color(0xFFC7B8F5); //0xffffe66d);
Color cWhite = Colors.white;
Color cBlack = Colors.black;
Color cLightText = Color(0xff031927);

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        primaryColor: cPrimary,
        fontFamily: 'Nunito',
        textTheme: const TextTheme(
          headline2: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        )),
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
      title: new Text('Welcome In Schoolapp bell'),
      backgroundColor: Colors.white,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      image: Image.asset("Assets/app_icon_beta.png"),
      loaderColor: cPrimary,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => MenuProvider(),
        child: new HomeScreen(),
      ),
      //debugShowCheckedModeBanner: false,
    );
  }
}
