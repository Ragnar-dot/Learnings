import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/start_screen.dart';
import '../screens/category_screen.dart';
import '../screens/video_screen.dart';
import '../screens/document_screen.dart';
import '../widgets/day_night_themed_switcher.dart';

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
                  'FIAE / FISI                Prüfungs-Trainer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            trailing: DayNightSwitch(
              initiallyDark: themeProvider.isDarkMode,
              onChange: (bool value) {
                themeProvider.toggleTheme();
              },
              size: 35,  // Größe des Switches
              duration: const Duration(milliseconds: 400),
            ),
          ),
          Divider(color: themeProvider.isDarkMode ? const Color.fromARGB(34, 243, 243, 243) : const Color.fromARGB(143, 231, 231, 231)),

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
         
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 0, 0, 0).withAlpha(7),
                  offset: const Offset(0, 2),
                  blurRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
