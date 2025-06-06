import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:report_app/features/reports/all_reports_screen.dart';
import 'package:report_app/features/reports/my_reports_screen.dart';
import 'package:report_app/features/reports/report_incident_screen.dart';
import 'package:report_app/features/home/home_screen.dart';
import 'package:report_app/features/user/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      AllReportsScreen(),
      ReportIncidentScreen(
        onReportSubmitted: (index) {
          _controller.jumpToTab(index);
        },
      ),
      MyReportsScreen(),
      ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: isDark ? Colors.white : Colors.indigo,
        inactiveColorPrimary: isDark ? Colors.grey[400]! : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.list_alt),
        title: ("All Reports"),
        activeColorPrimary: isDark ? Colors.white : Colors.indigo,
        inactiveColorPrimary: isDark ? Colors.grey[400]! : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add_circle),
        title: ("Report"),
        activeColorPrimary: isDark ? Colors.white : Colors.indigo,
        inactiveColorPrimary: isDark ? Colors.grey[400]! : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.report),
        title: ("My Reports"),
        activeColorPrimary: isDark ? Colors.white : Colors.indigo,
        inactiveColorPrimary: isDark ? Colors.grey[400]! : Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: isDark ? Colors.white : Colors.indigo,
        inactiveColorPrimary: isDark ? Colors.grey[400]! : Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(context),
      navBarStyle: NavBarStyle.style9,
      backgroundColor: isDark ? Colors.grey[900]! : Colors.white,
      confineToSafeArea: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(15.0),
        colorBehindNavBar: isDark ? Colors.black : Colors.white,
      ),
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
    );
  }
}
