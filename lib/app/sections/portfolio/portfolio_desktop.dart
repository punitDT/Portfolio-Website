import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysite/app/widgets/custom_text_heading.dart';
import 'package:mysite/core/configs/configs.dart';
import 'package:mysite/core/providers/public_data_provider.dart';
import 'package:mysite/core/color/colors.dart';
import 'package:sizer/sizer.dart';

import 'widgets/modern_project_card.dart';

class PortfolioDesktop extends StatefulWidget {
  const PortfolioDesktop({Key? key}) : super(key: key);

  @override
  State<PortfolioDesktop> createState() => _PortfolioDesktopState();
}

class _PortfolioDesktopState extends State<PortfolioDesktop> {
  int listLength = 3;

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
    Size size = MediaQuery.of(context).size;
    final dataProvider = Provider.of<PublicDataProvider>(context);

    // All data comes from Firebase only
    final projects = dataProvider.projects;
    final displayProjects = projects.take(listLength).toList();

    // Show loading state
    if (dataProvider.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: size.width / 8),
        height: 400,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (dataProvider.error != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: size.width / 8),
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to load projects',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                dataProvider.error!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (projects.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: size.width / 8),
        height: 400,
        child: const Center(
          child: Text(
            'No projects available',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: _getResponsivePadding(size.width), // Responsive padding
        right: _getResponsivePadding(size.width), // Responsive padding
        top: 4.w,
        bottom: 4.w,
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            margin: EdgeInsets.only(bottom: 4.w),
            child: Column(
              children: [
                const CustomSectionHeading(text: "Featured Projects"),
                Space.y(1.w)!,
                Container(
                  constraints: BoxConstraints(maxWidth: size.width * 0.6),
                  child: CustomSectionSubHeading(
                    text: dataProvider.getContent('portfolio_sub_heading',
                      defaultValue: "Since the beginning of my journey as a developer, I have created digital products for business and consumer use. This is a little bit."),
                  ),
                ),
              ],
            ),
          ),

          // Projects Grid
          if (dataProvider.isLoading)
            SizedBox(
              height: 400,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildProjectsGrid(displayProjects, size),

          Space.y(4.w)!,

          // Show "See More" button if there are more projects
          if (listLength < projects.length)
            _buildSeeMoreButton(projects),
        ],
      ),
    );
  }

  Widget _buildProjectsGrid(List projects, Size size) {
    // Calculate responsive grid layout
    int crossAxisCount = 2;
    if (size.width > 1400) {
      crossAxisCount = 3;
    } else if (size.width > 1000) {
      crossAxisCount = 2;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: size.width * 0.02, // 2% of screen width
        mainAxisSpacing: size.width * 0.02, // 2% of screen width
        childAspectRatio: 1.2, // Adjust for better proportions
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ModernProjectCard(project: project);
      },
    );
  }

  Widget _buildSeeMoreButton(List projects) {
    return Container(
      decoration: BoxDecoration(
        gradient: buttonGradi,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() => listLength = projects.length);
        },
        icon: const Icon(Icons.arrow_forward_rounded, color: whiteColor),
        label: const Text(
          'View All Projects',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: whiteColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
