import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/custom_text_heading.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:sizer/sizer.dart';

import 'widgets/firestore_project_card.dart';

class PortfolioMobileTab extends StatelessWidget {
  const PortfolioMobileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final dataProvider = Provider.of<PublicDataProvider>(context);

    // All data comes from Firebase only
    final projects = dataProvider.projects;

    return Column(
      children: [
        const CustomSectionHeading(text: "\nProjects"),
        Space.y(3.w)!,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: CustomSectionSubHeading(
            text: dataProvider.getContent('portfolio_sub_heading',
                defaultValue: "Since the beginning of my journey as a developer, I have created digital products for business and consumer use. This is a little bit."),
          ),
        ),
        Space.y(5.w)!,
        if (dataProvider.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (dataProvider.error != null)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load projects'),
                  const SizedBox(height: 8),
                  Text(
                    dataProvider.error!,
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else if (projects.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No projects available'),
            ),
          )
        else
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            clipBehavior: Clip.none, // Prevent clipping of content
            child: CarouselSlider.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int itemIndex, int i) {
                final project = projects[i];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w), // Reduced margin
                  clipBehavior: Clip.none, // Prevent clipping of card content
                  child: FirestoreProjectCard(project: project),
                );
              },
              options: CarouselOptions(
                height: height * 0.4,
                viewportFraction: 0.8, // Reduced to prevent overflow
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                enlargeCenterPage: true,
                enlargeFactor: 0.15, // Reduced enlarge factor to prevent overflow
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enableInfiniteScroll: false,
                padEnds: true, // Add padding at ends
              ),
            ),
          ),
        Space.y(3.w)!,
        // Removed GitHub navigation - keeping only in contact section
      ],
    );
  }
}
