import 'package:ensam_assisstant/Screens/menu_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'page_structure.dart';

String briefIconAdress = 'Assets/icons8-brief-90.png',
attendanceIconAdress = 'Assets/icons8-attendance-100.png',
gradesIconAdress = 'Assets/icons8-grades-100.png';

class HomeScreen extends StatefulWidget {
  List<MenuItem> mainMenu = [
    MenuItem.image("Personal Info", briefIconAdress, 0, data.pInfo.elemCurrent),
    MenuItem.image("Calendar", attendanceIconAdress, 1,  data.pInfo.elemCurrent),
    MenuItem.image("Elements", gradesIconAdress, 2, data.pInfo.elemCurrent),
    MenuItem.image("Modules", gradesIconAdress, 3, data.pInfo.moduleCurrent),
    MenuItem.image("Semester", gradesIconAdress, 4, data.pInfo.semester),
    MenuItem.image("Absence", attendanceIconAdress, 5, data.pInfo.attendance),
    //MenuItem("Notifications", Icons.notifications, 4, data.pInfo.markCurrent),
    MenuItem("Settings", Icons.settings, 6, data.pInfo.elemCurrent),
    MenuItem("About Us", Icons.info_outline, 7, data.pInfo.elemCurrent),

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
        (new HomeScreen()).mainMenu,
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
