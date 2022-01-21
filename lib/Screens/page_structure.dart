import 'dart:io';
import 'dart:math' show pi;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';

import 'Pages/AboutUs.dart';
import 'Pages/HomeScreenGUI.dart';
import 'Pages/NotifHistP.dart';
import 'mainGUI.dart';
import 'table_data_cleaner.dart';
import 'Pages/SettingsScreen.dart';

import '../main.dart';

class PageStructure extends StatelessWidget {
  final String? title;
  final Widget? child;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;

  const PageStructure({
    Key? key,
    this.title,
    this.child,
    this.actions,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final angle = 180 * pi;
    final _currentPage =
        context.select<MenuProvider, int>((provider) => provider.currentPage);
    var tmpCnt;

    if (_currentPage == 0)
      tmpCnt = HomeScreenGUI();
    //else if (_currentPage == 4) tmpCnt = NotifHistP();
    else if (_currentPage == 4)
      tmpCnt = SettingsScreen();
    else if (_currentPage == 5)
      tmpCnt = AboutUs();
    else
      tmpCnt = Container(
        color: Colors.grey[300],
        child: new TableWidgetCleaner(
            key: Key(_currentPage.toString()),
            dl: (new HomeScreen()).mainMenu[_currentPage].dataList),
      );

    final container = tmpCnt;
    final color = Theme.of(context).accentColor;
    final style = TextStyle(color: color);

    return PlatformScaffold(
      backgroundColor: Colors.transparent,
      appBar: PlatformAppBar(
        automaticallyImplyLeading: false,
        material: (_, __) => MaterialAppBarData(elevation: elevation),
        title: PlatformText(
          (new HomeScreen()).mainMenu[_currentPage].title,
        ),
        leading: Transform.rotate(
          angle: angle,
          child: PlatformIconButton(
            icon: Icon(
              Icons.menu,
            ),
            onPressed: () {
              ZoomDrawer.of(context)!.toggle();
            },
          ),
        ),
        trailingActions: actions,
      ),
      /*bottomNavBar: PlatformNavBar(
        material: (_, __) => MaterialNavBarData(
          selectedLabelStyle: style,
        ),
        currentIndex: _currentPage,
        itemChanged: (index) => Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(index),
        items: HomeScreen.mainMenu
            .map(
              (item) => BottomNavigationBarItem(
            label: item.title,
            icon: Icon(
              item.icon,
              color: color,
            ),
          ),
        )
            .toList(),
      ),*/
      body: kIsWeb
          ? container
          : Platform.isAndroid
              ? container
              : SafeArea(
                  child: container,
                ),
    );
  }
}
