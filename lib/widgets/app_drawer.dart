import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/start_screen.dart';
import '../screens/category_screen.dart';
import '../screens/video_screen.dart';
import '../screens/document_screen.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school, // icon
                  color: Colors.white,
                  size: 50,
                ),
                SizedBox(height: 9),
                Text(
                  'FIAE / FISI  Prüfungs-Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: Text(themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeProvider.isDarkMode
                  ? AppTheme.primaryColor
                  : Colors.amber,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Startseite'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StartScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kategorien'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Lernvideos'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_present),
            title: const Text('Dokumente'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DocumentScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Abmelden'),
            onTap: _isLoading ? null : _handleLogout,
          ),
        ],
      ),
    );
  }
}
