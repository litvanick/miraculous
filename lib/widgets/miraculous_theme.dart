import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension BuildContextExtension on BuildContext {
  MiraculousTheme get theme => Theme.of(this).extension<MiraculousTheme>()!;

  set theme(MiraculousTheme newTheme) => Provider.of<MiraculousThemeModel>(this, listen: false).theme = newTheme;
}

class MiraculousThemeModel with ChangeNotifier {
  MiraculousThemeModel(this._theme);

  MiraculousTheme _theme;

  MiraculousTheme get theme => _theme;

  set theme(MiraculousTheme theme) {
    _theme = theme;
    _saveTheme(theme);
    notifyListeners();
  }

  void _saveTheme(MiraculousTheme themeData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', themeData.name);
  }
}

class MiraculousApp extends StatelessWidget {
  MiraculousApp({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;
  
  Future<MiraculousTheme> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme') ?? 'Ladybug';
    if (themeStr == 'Chat Noir') return MiraculousTheme.chatnoir;
    return MiraculousTheme.ladybug;
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('images/icon.png'), context);
    precacheImage(AssetImage('images/ladybug_bg.jpg'), context);
    precacheImage(AssetImage('images/chatnoir_bg.jpg'), context);
    precacheImage(AssetImage('images/ladybug_loading.png'), context);
    precacheImage(AssetImage('images/chatnoir_loading.png'), context);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    final themeFuture = getTheme();
    return FutureBuilder<MiraculousTheme>(
      future: themeFuture,
      builder: (context, snapshot) {
        if (snapshot.data == null) return SizedBox.shrink();
        return ChangeNotifierProvider<MiraculousThemeModel>(
          create: (context) => MiraculousThemeModel(snapshot.data!),
          child: child,
          builder: (context, child) {
            return Consumer<MiraculousThemeModel>(
              child: child,
              builder: (context, themeModel, child) {
                return MaterialApp(
                  title: 'Miraculous Spoilers',
                  theme: ThemeData.light().copyWith(
                    extensions: [themeModel.theme],
                  ),
                  darkTheme: ThemeData.dark().copyWith(
                    extensions: [themeModel.theme],
                  ),
                  home: child,
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        );
      },
    );
  }
}

class MiraculousTheme extends ThemeExtension<MiraculousTheme> {
  static final ladybug = MiraculousTheme(
    name: 'Ladybug',
    primaryColor: Color(0xFFDD0000),
    secondaryColor: Color(0xFF696969),
    surfaceColor: Colors.red[300]!,
    linkColor: Colors.lightBlue[100]!,
    indicatorColor: Colors.grey[400]!,
    navigationColor: Color(0xFF323232),
    onPrimaryColor: Colors.white,
    onSecondaryColor: Colors.white,
    onSurfaceColor: Colors.black,
    onIndicatorColor: Color(0xFFDD0000),
    onImageColor: Colors.white,
    selectedColor: Colors.white,
    unselectedColor: Colors.grey[400]!,
    backgroundImage: AssetImage('images/ladybug_bg.jpg'),
    loadingImage: AssetImage('images/ladybug_loading.png'),
  );

  static final chatnoir = MiraculousTheme(
    name: 'Chat Noir',
    primaryColor: Color(0xFF161616),
    secondaryColor: Color(0xFFDEFFDE),
    surfaceColor: Colors.grey[700]!,
    linkColor: Colors.lightGreenAccent[400]!,
    indicatorColor: Color(0xFF161616),
    navigationColor: Colors.grey[900]!,
    onPrimaryColor: Colors.lightGreenAccent[400]!,
    onSecondaryColor: Colors.grey[700]!,
    onSurfaceColor: Color(0xFFDEFFDE),
    onIndicatorColor: Colors.lightGreenAccent[400]!,
    onImageColor: Colors.white,
    selectedColor: Colors.lightGreenAccent[400]!,
    unselectedColor: Color(0xFFDEFFDE),
    backgroundImage: AssetImage('images/chatnoir_bg.jpg'),
    loadingImage: AssetImage('images/chatnoir_loading.png'),
  );

  const MiraculousTheme({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.linkColor,
    required this.indicatorColor,
    required this.navigationColor,
    required this.onPrimaryColor,
    required this.onSecondaryColor,
    required this.onSurfaceColor,
    required this.onIndicatorColor,
    required this.onImageColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundImage,
    required this.loadingImage,
  });

  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color linkColor;
  final Color indicatorColor;
  final Color navigationColor;
  final Color onPrimaryColor;
  final Color onSecondaryColor;
  final Color onSurfaceColor;
  final Color onIndicatorColor;
  final Color onImageColor;
  final Color selectedColor;
  final Color unselectedColor;
  final ImageProvider backgroundImage;
  final ImageProvider loadingImage;
  
  @override
  ThemeExtension<MiraculousTheme> copyWith() {
    // Unimplemented
    return this;
  }
  
  @override
  ThemeExtension<MiraculousTheme> lerp(ThemeExtension<MiraculousTheme>? other, double t) {
    // Unimplemented
    return other ?? this;
  }
}
