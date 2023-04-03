import 'package:flutter/material.dart';
import 'package:mysite/app/utils/project_utils.dart';
import 'package:mysite/app/widgets/custom_text_heading.dart';
import 'package:mysite/changes/strings.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:sizer/sizer.dart';

import 'widgets/project_card.dart';

class PortfolioDesktop extends StatefulWidget {
  const PortfolioDesktop({Key? key}) : super(key: key);

  @override
  State<PortfolioDesktop> createState() => _PortfolioDesktopState();
}

class _PortfolioDesktopState extends State<PortfolioDesktop> {
  int listLength = 3;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width / 8),
      child: Column(
        children: [
          const CustomSectionHeading(text: "\nProjects"),
          Space.y(1.w)!,
          CustomSectionSubHeading(text: protfolioSubHeading),
          Space.y(2.w)!,
          ListView.separated(
            itemCount: listLength,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) =>
                ProjectCard(project: projectUtils[index]),
            separatorBuilder: (context, index) => const SizedBox(height: 80),
          ),
          /*Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runSpacing: 3.w,
            children: projectUtils
                .asMap()
                .entries
                .map(
                  (e) => ProjectCard(project: e.value),
                )
                .toList(),
          ),*/
          Space.y(3.w)!,
          listLength == projectUtils.length
              ? const SizedBox.shrink()
              : OutlinedButton(
                  //onPressed: () => openURL(gitHub),
                  onPressed: () =>
                      setState(() => listLength = projectUtils.length),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'See More',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
