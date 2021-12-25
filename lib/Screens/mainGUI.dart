import 'package:ensam_assisstant/Screens/menu_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'page_structure.dart';

class HomeScreen extends StatefulWidget {
  static List<MenuItem> mainMenu = [
    MenuItem("Personal Info", Icons.payment, 0, data.pInfo.markCurrent),
    MenuItem("Elements Marks", Icons.help, 1, data.pInfo.markCurrent),
    MenuItem("Modules Marks", Icons.help, 2, data.pInfo.moduleCurrent),
    MenuItem("Nonattendance", Icons.card_giftcard, 3, data.pInfo.attendance),
    MenuItem("Notifications", Icons.notifications, 4, data.pInfo.markCurrent),
    MenuItem("Settings", Icons.settings, 5, data.pInfo.markCurrent),
    MenuItem("About Us", Icons.info_outline, 6, data.pInfo.markCurrent),
  ];

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drawerController = ZoomDrawerController();

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      style: DrawerStyle.Style1,
      menuScreen: MenuScreen(
        HomeScreen.mainMenu,
        callback: _updatePage,
        current: _currentPage,
      ),
      mainScreen: MainScreen(),
      borderRadius: 24.0,
      showShadow: true,
      angle: 0.0,
      mainScreenScale: .1,
//      slideWidth:
//      MediaQuery.of(context).size.width * (ZoomDrawer.isRTL() ? .55 : 0.65),
      // openCurve: Curves.fastOutSlowIn,
      // closeCurve: Curves.bounceIn,
    );
  }

  void _updatePage(index) {
    Provider.of<MenuProvider>(context, listen: false).updateCurrentPage(index);
    _drawerController.toggle!();
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final rtl = true;
    return ValueListenableBuilder<DrawerState>(
      valueListenable: ZoomDrawer.of(context)!.stateNotifier!,
      builder: (context, state, child) {
        return AbsorbPointer(
          absorbing: state != DrawerState.closed,
          child: child,
        );
      },
      child: GestureDetector(
        child: PageStructure(),
        onPanUpdate: (details) {
          if (details.delta.dx < 6 && !rtl || details.delta.dx < -6 && rtl) {
            ZoomDrawer.of(context)?.toggle();
          }
        },
      ),
    );
  }
}

class MenuProvider extends ChangeNotifier {
  int _currentPage = 0;

  int get currentPage => _currentPage;

  void updateCurrentPage(int index) {
    if (index != currentPage) {
      _currentPage = index;
      bool h = hasListeners;
      notifyListeners();
    }
  }
}