import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/custom_text_heading.dart';

import 'package:mysite/core/color/colors.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/util/constants.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:sizer/sizer.dart';

class ContactDesktop extends StatelessWidget {
  const ContactDesktop({Key? key}) : super(key: key);

  // Helper method for responsive padding
  double _getResponsivePadding(double screenWidth) {
    if (screenWidth > 1400) {
      return screenWidth * 0.08; // 8% for very large screens
    } else if (screenWidth > 1200) {
      return screenWidth * 0.06; // 6% for large screens
    } else if (screenWidth > 1000) {
      return screenWidth * 0.05; // 5% for medium screens
    } else {
      return screenWidth * 0.04; // 4% for smaller screens
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<PublicDataProvider>(context);
    return Container(
      // padding: Space.all(1, 1),
      // padding: EdgeInsets.symmetric(horizontal: AppDimensions.normalize(30)),
      padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(size.width)),
      child: Column(
        children: [
          CustomSectionHeading(text: dataProvider.getContent('contact_section_heading', defaultValue: "\nGet in Touch")),
          Space.y(1.w)!,
          CustomSectionSubHeading(
            text: dataProvider.getContent('contact_section_sub_heading',
                defaultValue: "If you want to avail my services you can contact me at the links below."),
          ),
          Space.y(2.w)!,
          Container(
            padding: EdgeInsets.all(size.width * 0.05).copyWith(bottom: 10),
            decoration: BoxDecoration(
              gradient: theme.contactCard,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [modernCardShadow],
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataProvider.getContent('contact_heading', defaultValue: "Let's try my service now!"),
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Space.y(1.w)!,
                        Text(
                          dataProvider.getContent('contact_sub_heading', defaultValue: "Let's work together and make everything super cute and super useful."),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Space.y(2.w)!,
                        // SizedBox(height: AppDimensions.space(3)),
                      ],
                    ),
                    InkWell(
                      onTap: () => openURL(dataProvider.getContent('whatsapp_url', defaultValue: 'https://api.whatsapp.com/send?phone=9724117174')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        decoration: BoxDecoration(
                            gradient: buttonGradi,
                            // border: Border.all(
                            //     width: 2.0, color: theme.primaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(color: Colors.white.withOpacity(0.2), height: 1),
                Space.y(2.w)!,
                Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 50,
                    children: [
                      // GitHub
                      IconButton(
                        icon: Image.network(
                          "https://img.icons8.com/ios-glyphs/60/000000/github.png",
                          color: theme.textColor,
                        ),
                        onPressed: () => openURL(dataProvider.getContent('github_url', defaultValue: 'https://github.com/punitDT')),
                        highlightColor: Colors.white54,
                        iconSize: 21,
                      ),
                      // WhatsApp
                      IconButton(
                        icon: Image.network(
                          "https://img.icons8.com/material-outlined/48/000000/whatsapp.png",
                          color: theme.textColor,
                        ),
                        onPressed: () => openURL(dataProvider.getContent('whatsapp_url', defaultValue: 'https://api.whatsapp.com/send?phone=9724117174')),
                        highlightColor: Colors.white54,
                        iconSize: 21,
                      ),
                      // LinkedIn
                      IconButton(
                        icon: Image.network(
                          "https://img.icons8.com/ios-filled/50/000000/linkedin.png",
                          color: theme.textColor,
                        ),
                        onPressed: () => openURL(dataProvider.getContent('linkedin_url', defaultValue: 'https://www.linkedin.com/in/punit-patel-67906874')),
                        highlightColor: Colors.white54,
                        iconSize: 21,
                      ),
                      // Upwork
                      IconButton(
                        icon: Image.network(
                          "https://img.icons8.com/ios-filled/50/000000/upwork.png",
                          color: theme.textColor,
                        ),
                        onPressed: () => openURL(dataProvider.getContent('upwork_url', defaultValue: 'https://www.upwork.com/freelancers/~01e0dff917f3bdff40')),
                        highlightColor: Colors.white54,
                        iconSize: 21,
                      ),
                    ]),
              ],
            ),
          ),
          // Space.y!,
        ],
      ),
    );
  }
}
