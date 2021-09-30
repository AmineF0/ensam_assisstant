import 'dart:io';

import 'package:ensam_assisstant/Screens/mainGUI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ensam_assisstant/main.dart';

class MenuScreen extends StatefulWidget {
  final List<MenuItem> mainMenu;
  final Function(int)? callback;
  final int? current;

  MenuScreen(
      this.mainMenu, {
        Key? key,
        this.callback,
        this.current,
      });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final widthBox = SizedBox(
    width: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle androidStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white);
    final TextStyle iosStyle = const TextStyle(color: Colors.white);
    final style = kIsWeb
        ? androidStyle
        : Platform.isAndroid
        ? androidStyle
        : iosStyle;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.indigo,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                child: Image.file(
                  File(data.directory!.path+'/img.jpeg'),
                  width: 90,
                  height: 90,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 36.0, left: 24.0, right: 24.0),
                child: Text(
                  data.getName(),
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Selector<MenuProvider, int>(
                selector: (_, provider) => provider.currentPage,
                builder: (_, index, __) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ...widget.mainMenu
                        .map((item) => MenuItemWidget(
                      key: Key(item.index.toString()),
                      item: item,
                      callback: widget.callback!,
                      widthBox: widthBox,
                      style: style,
                      selected: index == item.index,
                    ))
                        .toList()
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: OutlinedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "logout",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 2.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  onPressed : () async {
                    await data.forgetCred();
                    Navigator.replace(context,oldRoute: ModalRoute.of(context)!,
                        newRoute: MaterialPageRoute(builder: (BuildContext context) => new SignIn()));
                  },
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem? item;
  final Widget? widthBox;
  final TextStyle? style;
  final Function? callback;
  final bool? selected;

  final white = Colors.white;

  const MenuItemWidget({
    Key? key,
    this.item,
    this.widthBox,
    this.style,
    this.callback,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => callback!(item!.index),
      style: TextButton.styleFrom(
        primary: selected! ? Color(0x44000000) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            item!.icon,
            color: white,
            size: 24,
          ),
          widthBox!,
          Expanded(
            child: Text(
              item!.title,
              style: style,
            ),
          )
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final int index;
  dynamic dataList;

  MenuItem(this.title, this.icon, this.index, this.dataList);
}