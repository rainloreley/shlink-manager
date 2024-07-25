import 'package:flutter/material.dart';
import 'package:shlink_app/views/login_view.dart';
import 'package:shlink_app/views/navigationbar_view.dart';
import 'globals.dart' as globals;
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ColorScheme _defaultLightColorScheme =
      ColorScheme.fromSeed(seedColor: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.blue,
      background: Colors.black);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
          title: 'Shlink',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xfffafafa),
              ),
              colorScheme: lightColorScheme ?? _defaultLightColorScheme,
              useMaterial3: true),
          darkTheme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xff0d0d0d),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: darkColorScheme?.copyWith(background: Colors.black) ??
                _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          home: const InitialPage());
    });
  }
}

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    bool result = await globals.serverManager.checkLogin();
    if (result) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NavigationBarView()),
              (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("")),
    );
  }
}
