import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:yelloskye/bloc/homwnavigation/homerounte_cubit.dart';
import 'package:yelloskye/bloc/project/project_cubit.dart';
import 'package:yelloskye/repositories/project_repository.dart';
import 'package:yelloskye/view/chart/chart.dart';
import 'package:yelloskye/view/map/mapscreen.dart';
import 'package:yelloskye/view/project/addproject/add.dart';
import 'package:yelloskye/view/project/project_screen.dart';
import '../core/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenContent();
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: _buildCurrentScreen(currentIndex),
          bottomNavigationBar: _buildGoogleBottomNavigationBar(
            context,
            currentIndex,
          ),
          floatingActionButton: _buildFloatingActionButton(
            context,
            currentIndex,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildCurrentScreen(int index) {
    final List<Widget> screens = [
      const ProjectScreen(),
      const MapScreen(),
      const ResponsiveChartScreen(),
    ];
    return screens[index];
  }

  Widget _buildGoogleBottomNavigationBar(
    BuildContext context,
    int currentIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: AppColors.primary.withOpacity(0.2),
            hoverColor: AppColors.primary.withOpacity(0.1),
            gap: 8,
            activeColor: Colors.white,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: AppColors.primary,
            color: AppColors.textSecondary,
            tabs: const [
              GButton(icon: Icons.work_outline, text: 'Projects'),
              GButton(icon: Icons.map_outlined, text: 'Map'),
              GButton(icon: Icons.bar_chart_outlined, text: 'Charts'),
            ],
            selectedIndex: currentIndex,
            onTabChange: (index) {
              context.read<NavigationCubit>().navigateTo(index);
            },
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, int currentIndex) {
    if (currentIndex != 0) return null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProjectScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(
          Icons.add_circle_outline,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'New Project',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  } 
}
