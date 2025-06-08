import 'package:flutter/material.dart';
import 'package:mysite/app/sections/contact/contact.dart';
import 'package:mysite/app/sections/home/home.dart';
import 'package:mysite/app/sections/portfolio/portfolio.dart';
import 'package:mysite/app/sections/services/services.dart';
import 'package:mysite/app/widgets/footer.dart';
import 'package:mysite/core/providers/scroll_provider.dart';
import 'package:provider/provider.dart';

class BodyUtils {
  static List<Widget> getViews(BuildContext context) {
    final scrollProvider = Provider.of<ScrollProvider>(context, listen: false);

    return [
      Container(
        key: scrollProvider.sectionKeys[0],
        child: const HomePage(),
      ),
      Container(
        key: scrollProvider.sectionKeys[1],
        child: const Services(),
      ),
      Container(
        key: scrollProvider.sectionKeys[2],
        child: const Portfolio(),
      ),
      Container(
        key: scrollProvider.sectionKeys[3],
        child: const Contact(),
      ),
      Container(
        key: scrollProvider.sectionKeys[4],
        child: const Footer(),
      ),
    ];
  }

  // Keep the old static list for backward compatibility
  static const List<Widget> views = [
    HomePage(),
    Services(),
    Portfolio(),
    Contact(),
    Footer(),
  ];
}
