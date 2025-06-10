part of 'services.dart';

class ServiceMobile extends StatelessWidget {
  const ServiceMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<PublicDataProvider>(context);

    // All data comes from Firebase only
    final services = dataProvider.services;

    // Show loading state
    if (dataProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (dataProvider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
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

    return Column(
      children: [
        const CustomSectionHeading(text: '\nWhat I can do?'),
        Space.y(3.w)!,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: CustomSectionSubHeading(
            text: dataProvider.getContent('services_sub_heading',
              defaultValue: "Since the beginning of my journey as a freelance designer and developer, I've worked in startups and collaborated with talented people to create digital products for both business and consumer use. I offer a wide range of services, including programming and development."),
          ),
        ),
        Space.y(5.w)!,
        if (services.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No services available'),
            ),
          )
        else
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            clipBehavior: Clip.none, // Prevent clipping of content
            child: CarouselSlider.builder(
              key: const ValueKey('services_carousel'), // Unique key for carousel
              itemCount: services.length,
              itemBuilder: (BuildContext context, int itemIndex, int i) => Container(
                key: ValueKey('service_card_${services[i].id ?? services[i].name}_$i'), // Unique key for each card
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                clipBehavior: Clip.none, // Prevent clipping of card content
                child: _FirestoreServiceCard(
                  key: ValueKey('service_${services[i].id ?? services[i].name}'), // Unique key for service card
                  service: services[i],
                ),
              ),
              options: CarouselOptions(
                viewportFraction: 0.85, // Slightly reduced to prevent overflow
                height: 400, // Increased height for mobile content
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                enlargeCenterPage: true,
                enlargeFactor: 0.2, // Reduced enlarge factor to prevent overflow
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                enableInfiniteScroll: false,
                padEnds: true, // Add padding to prevent edge clipping
              ),
            ),
          )
      ],
    );
  }
}
