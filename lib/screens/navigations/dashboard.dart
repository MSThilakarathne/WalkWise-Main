import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:walkwise/constants/app_assets.dart';
import 'package:walkwise/constants/colors.dart';
import 'package:walkwise/screens/navigations/home_page.dart';
import 'package:walkwise/screens/navigations/map_page.dart';
import 'package:walkwise/screens/navigations/settings_page.dart';
import 'package:walkwise/screens/navigations/suggest_places.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<Widget> tabItems = [
    Center(
      child: HomePage(),
    ),
    Center(
      child: MapPage(),
    ),
    Center(
      child: SuggestPlaces(),
    ),
    Center(
      child: SettingsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabItems[selectedIndex],
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.linear,
        selectedIndex: selectedIndex,
        iconSize: 24,
        showElevation: true,
        backgroundColor: AppColors.background,
        onItemSelected: (index) => setState(() {
          selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: SvgPicture.asset(
              AppAssets.homeIcon,
              colorFilter: ColorFilter.mode(
                selectedIndex == 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            title: Text('Home', style: TextStyle(color: AppColors.text)),
          ),
          FlashyTabBarItem(
            icon: SvgPicture.asset(
              AppAssets.locationIcon,
              colorFilter: ColorFilter.mode(
                selectedIndex == 1
                    ? AppColors.primary
                    : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            title: Text('Map', style: TextStyle(color: AppColors.text)),
          ),
          FlashyTabBarItem(
            icon: SvgPicture.asset(
              AppAssets.routingIcon,
              colorFilter: ColorFilter.mode(
                selectedIndex == 2
                    ? AppColors.primary
                    : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            title: Text('Places', style: TextStyle(color: AppColors.text)),
          ),
          FlashyTabBarItem(
            icon: SvgPicture.asset(
              AppAssets.settingIcon,
              colorFilter: ColorFilter.mode(
                selectedIndex == 3
                    ? AppColors.primary
                    : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            title: Text('Settings', style: TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}
