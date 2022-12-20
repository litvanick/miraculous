import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '/widgets/miraculous_theme.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({Key? key, required this.pageController, required this.count}) : super(key: key);

  final PageController pageController;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.0,
      child: SmoothPageIndicator(
        controller: pageController,
        count: count,
        onDotClicked: (index) {
          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOutCubic
          );
        },
        effect: SlideEffect(
          radius: 4.0,
          dotWidth: 8.0,
          dotHeight: 8.0,
          activeDotColor: context.theme.selectedColor,
          dotColor: context.theme.unselectedColor,
        ),
      ),
    );
  }
}
