import 'dart:math' show pi;

import 'package:ensam_assisstant/Screens/Components/AttendanceUI/AttendanceMenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'Pages/AboutUs.dart';
import 'Pages/Calendar.dart';
import 'Pages/HomeScreenGUI.dart';
import 'SemesterGUI.dart';
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
    

    switch (_currentPage) {
      case 0: tmpCnt = HomeScreenGUI(); break;
      case 1: tmpCnt = Calendar(); break;
      case 2: tmpCnt = TableWidgetCleaner(data: data.pInfo.markCurrent); break;
      case 3: tmpCnt = TableWidgetCleaner(data: data.pInfo.moduleCurrent); break;
      case 4: tmpCnt = SemesterGUI(data: data.pInfo.semester); break;
      case 5: tmpCnt = AttendaceMenu(); break;
      case 6: tmpCnt = SettingsScreen(); break;
      case 7: tmpCnt = AboutUs(); break;
      case 9: tmpCnt = Text(data.log); break;
      default:tmpCnt = Container(
          color: Colors.grey[300],
          child: new TableWidgetCleaner(data: data.pInfo.markCurrent),
          );
    }

    final container = tmpCnt;
    final color = Theme.of(context).primaryColor;
    final style = TextStyle(color: color);

    return PlatformScaffold(
        backgroundColor: Colors.transparent,
        appBar: PlatformAppBar(
          backgroundColor: color,
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

        body: container);
  }
}
