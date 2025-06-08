import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrollProvider extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final scrollDuration = const Duration(seconds: 1);

  // Store section keys for precise positioning
  final List<GlobalKey> sectionKeys = [
    GlobalKey(), // Home
    GlobalKey(), // Services
    GlobalKey(), // Portfolio
    GlobalKey(), // Contact
    GlobalKey(), // Footer
  ];

  void jumpTo(int index, [BuildContext? context]) {
    if (index < 0 || index >= sectionKeys.length) return;

    // Use improved positioning with better scroll behavior
    _jumpToSection(index, context);

    // Alternative: Try GlobalKey as secondary attempt
    Future.delayed(const Duration(milliseconds: 100), () {
      final key = sectionKeys[index];
      final renderObject = key.currentContext?.findRenderObject();

      if (renderObject is RenderBox && scrollController.hasClients) {
        try {
          final position = renderObject.localToGlobal(Offset.zero);
          double targetOffset = position.dy;

          // Adjust for navbar height
          if (index > 0) {
            targetOffset = targetOffset - 120;
          }

          // Only adjust if the difference is significant
          final currentOffset = scrollController.offset;
          if ((targetOffset - currentOffset).abs() > 50) {
            scrollController.animateTo(
              targetOffset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
            );
          }
        } catch (e) {
          // Ignore errors in secondary positioning
        }
      }
    });
  }

  void _jumpToSection(int index, BuildContext? context) {
    if (!scrollController.hasClients) return;

    try {
      // Try GlobalKey positioning first
      final renderObject = sectionKeys[index].currentContext?.findRenderObject();

      if (renderObject is RenderBox) {
        final position = renderObject.localToGlobal(Offset.zero);
        double targetOffset = position.dy;

        // Adjust for navbar height (120px)
        if (index > 0) {
          targetOffset = targetOffset - 120;
        }

        // Ensure target is within bounds
        targetOffset = targetOffset.clamp(0.0, scrollController.position.maxScrollExtent);

        scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        return;
      }
    } catch (e) {
      print('GlobalKey positioning failed: $e');
    }

    // Fallback to estimated positioning
    _jumpToEstimated(index, context);
  }

  void _jumpToEstimated(int index, BuildContext? context) {
    if (index >= 5) return; // Only 5 sections: Home, Services, Portfolio, Contact, Footer

    // Use fixed scroll positions that work reliably
    List<double> scrollPositions;

    if (context != null) {
      final size = MediaQuery.of(context).size;
      final height = size.height;

      // Direct scroll positions instead of cumulative heights
      scrollPositions = [
        0,                    // Home - Top of page
        height * 0.95,        // Services - After home section
        height * 1.9,         // Portfolio - After home + services
        height * 3.0,         // Contact - After home + services + portfolio
        height * 3.8,         // Footer - After all sections
      ];
    } else {
      // Fallback positions
      scrollPositions = [0, 950, 1900, 3000, 3800];
    }

    double targetOffset = scrollPositions[index];

    // Adjust for navbar height (except for home)
    if (index > 0) {
      targetOffset = targetOffset - 120;
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
