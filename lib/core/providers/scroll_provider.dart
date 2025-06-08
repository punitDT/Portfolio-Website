import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrollProvider extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final scrollDuration = const Duration(seconds: 1);

  // Section heights - approximate values, can be adjusted
  final List<double> sectionHeights = [
    800.0, // Home
    600.0, // Services
    800.0, // Portfolio
    600.0, // Contact
    100.0, // Footer
  ];

  void jumpTo(int index) {
    if (index < 0 || index >= sectionHeights.length) return;

    double targetOffset = 0;
    for (int i = 0; i < index; i++) {
      targetOffset += sectionHeights[i];
    }

    scrollController.animateTo(
      targetOffset,
      duration: scrollDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
