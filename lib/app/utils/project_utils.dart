class ProjectUtils {
  final String banners;
  final String icons;
  final String titles;
  final String description;
  final String? links;
  final String imageUrl;
  ProjectUtils({
    required this.banners,
    required this.icons,
    required this.titles,
    required this.description,
    this.links,
    required this.imageUrl,
  });
}

// Static project data removed - all data now comes from Firebase
List<ProjectUtils> projectUtils = [];
