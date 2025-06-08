import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/core/util/constants.dart';
import 'package:mysite/core/color/colors.dart';
import 'package:mysite/core/theme/app_theme.dart';
import 'package:mysite/core/providers/public_data_provider.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context);
    final dataProvider = Provider.of<PublicDataProvider>(context);

    return Container(
      margin: EdgeInsets.fromLTRB(0, height * 0.05, 0, 0),
      height: height * 0.08,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.brightness == Brightness.light
                ? primaryColor.withOpacity(0.05)
                : primaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: const SizedBox.shrink(), // Empty footer
    );
  }
}
