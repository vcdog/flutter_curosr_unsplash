import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';
import 'services/preferences_service.dart';
import 'pages/welcome_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(prefs);

  runApp(MyApp(preferencesService: preferencesService));
}

class MyApp extends StatelessWidget {
  final PreferencesService preferencesService;

  const MyApp({Key? key, required this.preferencesService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 关闭debug标签
      home: FutureBuilder<bool>(
        future: preferencesService.isWelcomeShown(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bool welcomeShown = snapshot.data ?? false;
          return welcomeShown
              ? const HomePage()
              : WelcomePage(preferencesService: preferencesService);
        },
      ),
    );
  }
}
