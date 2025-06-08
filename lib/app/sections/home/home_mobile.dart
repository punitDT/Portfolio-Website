import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/color_chage_btn.dart';
import 'package:mysite/core/animations/entrance_fader.dart';
import 'package:mysite/core/animations/zoom_animation.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/res/responsive_size.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import 'widgets/animation_text.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicDataProvider>(
      builder: (context, dataProvider, child) {
        return Padding(
          padding: EdgeInsets.only(
            left: 10.w,
            top: 15.h, // Increased to account for navbar height
            right: 10.w
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dataProvider.getContent('hello_tag', defaultValue: 'Hi there, Welcome to My Space'),
                    style: AppText.h3!.copyWith(fontSize: isFontSize(context, 16)),
                  ),

                ],
              ),
              // Space.y(1.w)!,
              Text(
                dataProvider.getContent('your_name', defaultValue: "I'm Punit Patel,"),
                style: TextStyle(
                  fontSize: isFontSize(context, 28),
                  fontWeight: FontWeight.w600,
                ),
              ),
          Space.y(1.w)!,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "A ",
                style: TextStyle(
                  fontSize: isFontSize(context, 18),
                  fontWeight: FontWeight.w400,
                ),
              ),
              AnimatedTextKit(
                animatedTexts: getMobileList(context),
                repeatForever: true,
                isRepeatingAnimation: true,
              ),
            ],
          ),

          Space.y(2.w)!,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ColorChageButton(
                text: 'download cv',
                onTap: () {
                  final resumeUrl = dataProvider.getContent('resume_url', defaultValue: 'https://drive.google.com/file/d/11SKV1YlDUEJJq5B7JYAFjSi8k2nmp-HC/view?usp=sharing');
                  html.window.open(resumeUrl, "pdf");
                },
              ),
              const EntranceFader(
                offset: Offset(0, 0),
                delay: Duration(seconds: 1),
                duration: Duration(milliseconds: 800),
                child: ZoomAnimations(),
              )
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}
