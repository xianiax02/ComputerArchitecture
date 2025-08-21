import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight = screenHeight * (50 / 780);

    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D54),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            height: navBarHeight,
            color: Colors.white.withOpacity(0.4),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.calendar_today, 0),
              _buildNavItem(Icons.list_alt, 1),
              _buildCentralNavItem(2, navBarHeight),
              _buildNavItem(Icons.bar_chart, 3),
              _buildNavItem(Icons.person, 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index ? const Color(0xFFFCF1A5) : const Color(0xFFA5B0FC),
        size: 30,
      ),
      onPressed: () => onItemTapped(index),
    );
  }

  Widget _buildCentralNavItem(int index, double navBarHeight) {
    final containerWidth = (56 / 50) * navBarHeight;
    final containerHeight = (40 / 50) * navBarHeight;
    final iconSize = containerHeight * 0.8;
    final isSelected = selectedIndex == index;
    final iconData = isSelected ? Icons.pause : Icons.play_arrow;

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3C),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        icon: Icon(
          iconData,
          color: isSelected ? const Color(0xFFFCF1A5) : const Color(0xFFA5B0FC),
          size: iconSize,
        ),
        onPressed: () => onItemTapped(index),
      ),
    );
  }
}
