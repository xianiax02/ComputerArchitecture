import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'custom_bottom_nav_bar.dart';

// 1. Provider
final selectedIndexProvider = StateNotifierProvider<SelectedIndexNotifier, int>((ref) {
  return SelectedIndexNotifier();
});

// 2. Notifier
class SelectedIndexNotifier extends StateNotifier<int> {
  SelectedIndexNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}


void main() {
  // 3. ProviderScope
  runApp(const ProviderScope(child: ScriberApp()));
}

class ScriberApp extends StatelessWidget {
  const ScriberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scriber',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D2D54),
        scaffoldBackgroundColor: const Color(0xFF2D2D54),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA5B0FC),
          secondary: Color(0xFFA5B0FC),
        ),
        fontFamily: 'BalooBhai',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF3C3C6E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFA5B0FC),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// 4. ConsumerWidget
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    CalendarScreen(),
    TaskScreen(),
    StartScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Watch the provider
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(selectedIndex)),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        // 6. Use the notifier to update the state
        onItemTapped: (index) => ref.read(selectedIndexProvider.notifier).setIndex(index),
      ),
    );
  }
}

// Placeholder screens for now
class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Task Screen'));
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Calendar Screen'));
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Statistics Screen'));
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Start Screen'));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Screen'));
  }
}
