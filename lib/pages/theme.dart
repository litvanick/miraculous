import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/miraculous_theme.dart';

class ThemePage extends StatelessWidget {
  ThemePage({super.key});

  @override
  Widget build(context) {
    return GridView.count(
      padding: const EdgeInsets.all(16.0),
      mainAxisSpacing: 16.0,
      crossAxisSpacing: 16.0,
      crossAxisCount: 2,
      children: [
        ThemeWidget(MiraculousTheme.ladybug),
        ThemeWidget(MiraculousTheme.chatnoir),
      ],
    );
  }
}

class ThemeWidget extends StatelessWidget {
  ThemeWidget(this.theme, {Key? key}) : super(key: key);

  final MiraculousTheme theme;

  @override
  Widget build(context) {
    final mainTheme = context.theme;
    return GestureDetector(
      onTap: () => context.theme = theme,
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: mainTheme == theme ? theme.onPrimaryColor : theme.primaryColor,
            width: 2.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 0.5,
              child: Image(
                image: theme.loadingImage,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  theme.name,
                  style: GoogleFonts.courgette(
                    color: theme.onPrimaryColor,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
