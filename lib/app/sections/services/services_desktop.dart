part of 'services.dart';

class ServiceDesktop extends StatefulWidget {
  const ServiceDesktop({Key? key}) : super(key: key);

  @override
  ServiceDesktopState createState() => ServiceDesktopState();
}

class ServiceDesktopState extends State<ServiceDesktop> {
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final dataProvider = Provider.of<PublicDataProvider>(context);

    // All data comes from Firebase only
    final services = dataProvider.services;

    // Show loading state
    if (dataProvider.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(width)),
        height: 400,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (dataProvider.error != null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: width / 8),
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load services'),
              const SizedBox(height: 8),
              Text(dataProvider.error!, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(width))
          .copyWith(bottom: height * 0.2),
      child: Column(
        children: [
          const CustomSectionHeading(text: '\nWhat I can do?'),
          Space.y(1.w)!,
          CustomSectionSubHeading(
            text: dataProvider.getContent('services_sub_heading',
              defaultValue: "Since the beginning of my journey as a freelance designer and developer, I've worked in startups and collaborated with talented people to create digital products for both business and consumer use. I offer a wide range of services, including programming and development."),
          ),
          Space.y(2.w)!,
          if (services.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No services available'),
              ),
            )
          else
            _buildServicesGrid(services, width, height)
        ],
      ),
    );
  }

  Widget _buildServicesGrid(List<ServiceModel> services, double width, double height) {
    // Calculate number of columns based on screen width
    int crossAxisCount = 4; // Default for large screens
    if (width < 1200) {
      crossAxisCount = 3;
    }
    if (width < 900) {
      crossAxisCount = 2;
    }

    // Calculate the number of rows needed
    int rowCount = (services.length / crossAxisCount).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        int startIndex = rowIndex * crossAxisCount;
        int endIndex = (startIndex + crossAxisCount).clamp(0, services.length);
        List<ServiceModel> rowServices = services.sublist(startIndex, endIndex);

        return Padding(
          padding: EdgeInsets.only(bottom: height * 0.05),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...rowServices.map((service) => Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.01), // Reduced padding
                    clipBehavior: Clip.none, // Prevent clipping of content
                    child: _FirestoreServiceCard(
                      key: ValueKey('desktop_service_${service.id ?? service.name}'), // Unique key for desktop
                      service: service,
                    ),
                  ),
                )),
                // Add empty expanded widgets to fill remaining space if needed
                ...List.generate(
                  crossAxisCount - rowServices.length,
                  (index) => const Expanded(child: SizedBox()),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
