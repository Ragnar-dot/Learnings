import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/start_screen.dart';
import '../screens/category_screen.dart';
import '../screens/video_screen.dart';
import '../screens/document_screen.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
            title: Text(
              themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                color: themeProvider.isDarkMode 
                    ? Colors.white 
                    : Colors.black87,
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                    ? const Color.fromARGB(255, 36, 36, 36)
                    : const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0,5),
                  ),
                ],
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode
                    ? const Color.fromARGB(255, 0, 162, 255)
                    : Colors.orange,
                size: 24,
              ),
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme();
            },
            activeColor: const Color.fromARGB(255, 31, 31, 31).withOpacity(0.95),  // Leicht transparenter weißer Kreis
            inactiveThumbColor: const Color.fromARGB(255, 70, 70, 70).withOpacity(0.95),
            activeTrackColor: const Color.fromARGB(255, 76, 175, 79).withOpacity(0.8),  // Leicht transparentes Grün
            inactiveTrackColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),  // Leicht transparentes Rot
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
        ],
      ),
    );
  }
}
