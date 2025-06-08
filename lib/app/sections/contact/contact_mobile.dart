import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/custom_text_heading.dart';

import 'package:mysite/core/color/colors.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/util/constants.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:sizer/sizer.dart';

class ContactMobileTab extends StatelessWidget {
  const ContactMobileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final dataProvider = Provider.of<PublicDataProvider>(context);
    return Column(
      children: [
        Space.y(10.w)!,
        CustomSectionHeading(text: dataProvider.getContent('contact_section_heading', defaultValue: "Get in Touch")),
        Space.y(3.w)!,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: CustomSectionSubHeading(text: dataProvider.getContent('contact_section_sub_heading',
              defaultValue: "If you want to avail my services you can contact me at the links below.")),
        ),
        Space.y(5.w)!,
        InkWell(
          onTap: () => openURL(dataProvider.getContent('whatsapp_url', defaultValue: 'https://api.whatsapp.com/send?phone=9724117174')),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              gradient: buttonGradi,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [modernCardShadow],
            ),
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: whiteColor,
              ),
            ),
          ),
        ),
        Space.y(10.w)!,
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
        Space.y(5.w)!,
        Container(color: Colors.white.withOpacity(0.2), height: 1),
      ],
    );
  }
}
