import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/start_screen.dart';
import 'theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Lade .env
  await SupabaseService.initialize();

  // Auskommentieren nach erstem erfolgreichen Import
  // await SupabaseService.importInitialDocuments();

  // Überprüfe ob die Dokumente geladen werden können
  final docs = await SupabaseService.getDocuments('all');
  print('Vorhandene Dokumente: $docs');

  // await SupabaseService.importQuestionsFromJson(); // Auskommentiert nach erfolgreichem Import

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..init(),
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Prüfungs-Quiz',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: SupabaseService.isAuthenticated ? '/home' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const StartScreen(),
          },
        );
      },
    );
  }
}
