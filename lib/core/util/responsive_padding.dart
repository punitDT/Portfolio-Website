/// Utility class for responsive padding calculations
class ResponsivePadding {
  /// Calculate responsive horizontal padding based on screen width
  /// This ensures consistent alignment across all sections while preventing overflow
  static double getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1400) {
      return screenWidth * 0.08; // 8% for very large screens (1400px+)
    } else if (screenWidth > 1200) {
      return screenWidth * 0.06; // 6% for large screens (1200px-1400px)
    } else if (screenWidth > 1000) {
      return screenWidth * 0.05; // 5% for medium screens (1000px-1200px)
    } else if (screenWidth > 800) {
      return screenWidth * 0.04; // 4% for smaller desktop screens (800px-1000px)
    } else {
      return screenWidth * 0.03; // 3% for very small screens (below 800px)
    }
  }

  /// Calculate responsive spacing for grids and layouts
  static double getSpacing(double screenWidth) {
    if (screenWidth > 1200) {
      return screenWidth * 0.02; // 2% spacing for large screens
    } else if (screenWidth > 800) {
      return screenWidth * 0.015; // 1.5% spacing for medium screens
    } else {
      return screenWidth * 0.01; // 1% spacing for small screens
    }
  }

  /// Calculate responsive grid spacing to prevent overflow
  static double getGridSpacing(double screenWidth) {
    if (screenWidth > 1400) {
      return 24.0; // Fixed spacing for very large screens
    } else if (screenWidth > 1200) {
      return 20.0; // Fixed spacing for large screens
    } else if (screenWidth > 1000) {
      return 16.0; // Fixed spacing for medium screens
    } else {
      return 12.0; // Fixed spacing for smaller screens
    }
  }
}
