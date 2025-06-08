import 'package:mysite/app/sections/home/widgets/animation_text.dart';
import 'package:mysite/core/animations/zoom_animation.dart';
import 'package:mysite/core/res/responsive_size.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/color_chage_btn.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:mysite/core/util/responsive_padding.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final dataProvider = Provider.of<PublicDataProvider>(context);
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: 80.h,
      child: Padding(
        padding: EdgeInsets.only(
          left: ResponsivePadding.getHorizontalPadding(size.width), // Responsive padding
          right: ResponsivePadding.getHorizontalPadding(size.width), // Responsive padding
          top: 120, // Account for navbar height
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                margin: EdgeInsets.only(top: 5.h), // Reduced since we added top padding
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(dataProvider.getContent('hello_tag', defaultValue: 'Hi there, Welcome to My Space'),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w100,
                          )),

                    ],
                  ),
                  Space.y(0.5.w)!,
                  Text(dataProvider.getContent('your_name', defaultValue: "I'm Punit Patel,"),
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("A ",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                          )),
                      AnimatedTextKit(
                        isRepeatingAnimation: true,
                        repeatForever: true,
                        animatedTexts: getDesktopList(context),
                      ),
                    ],
                  ),
                  Space.y(1.5.w)!,
                  Padding(
                    padding: EdgeInsets.only(right: 2.w), // Reduced padding
                    child: Text(dataProvider.getContent('mini_description', defaultValue: "Freelancer providing services for programming and design content needs. Join me down below and let's get started!"),
                        style: TextStyle(
                          fontSize: isFontSize(context, 20),
                          fontWeight: FontWeight.w400,
                          color: theme.textColor.withOpacity(0.6),
                        )),
                  ),
                  Space.y(3.w)!,
                  ColorChageButton(
                    text: 'download cv',
                    onTap: () {
                      final resumeUrl = dataProvider.getContent('resume_url', defaultValue: 'https://drive.google.com/file/d/11SKV1YlDUEJJq5B7JYAFjSi8k2nmp-HC/view?usp=sharing');
                      html.window.open(resumeUrl, "pdf");
                    },
                  ),
                ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: const ZoomAnimations(),
            ),
          ],
        ),
      ),
    );
  }
}
