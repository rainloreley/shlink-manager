import 'package:flutter/material.dart';
import 'package:shlink_app/views/login_view.dart';
import 'package:shlink_app/views/navigationbar_view.dart';
import 'globals.dart' as globals;
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _defaultLightColorScheme = ColorScheme
      .light(); //.fromSwatch(primarySwatch: Colors.blue, backgroundColor: Colors.white);

  static final _defaultDarkColorScheme =
      ColorScheme.fromSwatch(brightness: Brightness.dark);

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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: (locales, supportedLocales) {
            for (Locale locale in locales!) {
              if (supportedLocales.contains(locale) ||
                  supportedLocales.where((element) =>
                  element.languageCode == locale.languageCode).isNotEmpty) {
                return locale;
              }
            }
            return const Locale('en');
          },
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NavigationBarView()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("")),
    );
  }
}
