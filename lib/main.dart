import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'RuntimeData.dart';
import 'package:splashscreen/splashscreen.dart';
import 'Screens/SignInOne.dart';
import 'Screens/mainGUI.dart';

late RuntimeData data;

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
    data = new RuntimeData();
    await data.loadDirectory();
    var rs = await data.loadSession();
    if (rs) {
      await data.load();
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
