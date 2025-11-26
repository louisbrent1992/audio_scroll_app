import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/feed_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'providers/app_config_provider.dart';

void main() {
  runApp(const AudioScrollApp());
}

class AudioScrollApp extends StatelessWidget {
  const AudioScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppConfigProvider()..loadConfig(),
      child: Consumer<AppConfigProvider>(
        builder: (context, configProvider, _) {
          // Use server config theme if available, otherwise use default
          final theme = configProvider.config != null
              ? AppTheme.createThemeFromConfig(configProvider.config!.theme.toJson())
              : AppTheme.darkTheme;
          
    return MaterialApp(
            title: 'AudioScroll',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const MainNavigator(),
          );
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  bool _hasCompletedOnboarding = false; // In a real app, this would be stored in shared preferences

  @override
  void initState() {
    super.initState();
    // Check if user has completed onboarding
    // For now, we'll show onboarding on first launch
    _hasCompletedOnboarding = false;
  }
  
  void _onOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCompletedOnboarding) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          FeedScreen(),
          SearchScreen(),
          LibraryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Explore',
            ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
