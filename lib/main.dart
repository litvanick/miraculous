import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/art.dart';
import 'pages/countdown.dart';
import 'pages/spoiler.dart';
import 'pages/theme.dart';
import 'widgets/loading_controller.dart';
import 'widgets/miraculous_theme.dart';
import 'widgets/no_over_scroll.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MiraculousApp(
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var index = 0;

  final titles = <String>['Spoilers', 'Countdown', 'Art', 'Themes'];
  late final controllers = <LoadingController>[
    LoadingController('news', descending: true),
    LoadingController('countdowns', descending: false),
    LoadingController('arts', descending: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.navigationColor,
      ),
      child: Scaffold(
        backgroundColor: theme.navigationColor,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: theme.primaryColor,
          title: GestureDetector(
            onTap: () => index < 2 ? controllers[index].scrollUp() : null,
            child: SizedBox(
              width: double.infinity,
              child: Text(
                titles[index],
                style: TextStyle(color: theme.onPrimaryColor),
              ),
            ),
          ),
          actions: [
            if (index < controllers.length) IconButton(
              icon: Icon(Icons.refresh_outlined, color: theme.onPrimaryColor),
              onPressed: controllers[index].reload,
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: NoOverscroll(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: context.theme.backgroundImage,
                fit: BoxFit.cover,
              ) ,
            ),
            child: IndexedStack(
              index: index,
              children: [
                SpoilerPage(controllers[0]),
                CountDownPage(controllers[1]),
                ArtPage(controllers[2]),
                ThemePage(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          selectedItemColor: context.theme.selectedColor,
          unselectedItemColor: context.theme.unselectedColor,
          backgroundColor: context.theme.navigationColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message),
              backgroundColor: context.theme.navigationColor,
              label: titles[0],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.watch_later_outlined),
              activeIcon: Icon(Icons.watch_later),
              backgroundColor: context.theme.navigationColor,
              label: titles[1],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.palette_outlined),
              activeIcon: Icon(Icons.palette),
              backgroundColor: context.theme.navigationColor,
              label: titles[2],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              backgroundColor: context.theme.navigationColor,
              label: titles[3],
            ),
          ],
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}
