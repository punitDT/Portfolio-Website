import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/color/colors.dart';
import 'package:sizer/sizer.dart';

class ProjectDetailsDialog extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsDialog({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ProjectDetailsDialog> createState() => _ProjectDetailsDialogState();
}

class _ProjectDetailsDialogState extends State<ProjectDetailsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not launch $url'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening URL: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _openImageInBrowser(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(imageUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open image: $imageUrl'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error opening image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isMobile = size.width < 600;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? size.width * 0.1 : (isMobile ? 16 : 32),
              vertical: isDesktop ? size.height * 0.05 : (isMobile ? 20 : 40),
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: isDesktop
                    ? 900
                    : (isMobile ? size.width - 32 : size.width - 64),
                constraints: BoxConstraints(
                  maxHeight: isDesktop
                      ? size.height * 0.7
                      : (isMobile ? size.height * 0.8 : size.height * 0.75),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor.withOpacity(0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with banner image
                      _buildHeader(theme, isDesktop, isMobile),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.all(
                              isDesktop ? 32 : (isMobile ? 12 : 20)),
                          child: _buildContent(theme, isDesktop, isMobile),
                        ),
                      ),

                      // Actions
                      _buildActions(theme, isDesktop, isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDesktop, bool isMobile) {
    return Container(
      height: isDesktop ? 200 : (isMobile ? 120 : 150),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Image
          widget.project.bannerUrl.isNotEmpty
              ? (widget.project.bannerUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: widget.project.bannerUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.web_asset,
                              size: 50, color: Colors.white),
                        ),
                      ),
                    )
                  : Image.asset(
                      widget.project.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withOpacity(0.8),
                              primaryColor.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.web_asset,
                              size: 50, color: Colors.white),
                        ),
                      ),
                    ))
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        primaryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.web_asset, size: 50, color: Colors.white),
                  ),
                ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: isMobile ? 8 : 16,
            right: isMobile ? 8 : 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close,
                    color: Colors.white, size: isMobile ? 14 : 18),
                tooltip: 'Close',
              ),
            ),
          ),

          // Project Icon and Title
          Positioned(
            bottom: isMobile ? 8 : 16,
            left: isMobile ? 12 : 24,
            right: isMobile ? 12 : 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Icon
                if (widget.project.iconUrl.isNotEmpty)
                  Container(
                    width: isMobile ? 32 : 48,
                    height: isMobile ? 32 : 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isMobile ? 4 : 6),
                    child: widget.project.iconUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: widget.project.iconUrl,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.web_asset, size: isMobile ? 16 : 24),
                          )
                        : Image.asset(
                            widget.project.iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.web_asset, size: isMobile ? 16 : 24),
                          ),
                  ),

                SizedBox(width: isMobile ? 6 : 12),

                // Title
                Expanded(
                  child: Text(
                    widget.project.title,
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : (isMobile ? 16 : 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: isMobile ? 3 : 4,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDesktop, bool isMobile) {
    // Check if we have additional sections beyond description
    final hasTechnologies = widget.project.technologies.isNotEmpty;
    final hasImages = widget.project.sliderImages.isNotEmpty;
    final hasAdditionalSections = hasTechnologies || hasImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Section
        _buildSection(
          title: 'Description',
          icon: Icons.description,
          child: Text(
            widget.project.description,
            style: TextStyle(
              fontSize: isDesktop ? 16 : (isMobile ? 13 : 14),
              color: theme.textTheme.bodyLarge?.color,
              height: 1.6,
            ),
          ),
          isMobile: isMobile,
        ),

        // Divider after Description (only if there are additional sections)
        if (hasAdditionalSections) _buildDivider(isMobile),

        // Technologies Section
        if (hasTechnologies) ...[
          _buildSection(
            title: 'Technologies Used',
            icon: Icons.code,
            child: Wrap(
              spacing: isMobile ? 6 : 8,
              runSpacing: isMobile ? 6 : 8,
              children: widget.project.technologies.map((tech) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tech,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : (isMobile ? 11 : 12),
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            isMobile: isMobile,
          ),

          // Divider after Technologies (only if there are images)
          if (hasImages) _buildDivider(isMobile),
        ],

        // Project Images Section
        if (hasImages)
          _buildSection(
            title: 'Project Images (${widget.project.sliderImages.length})',
            icon: Icons.photo_library,
            child: _buildImageGrid(isDesktop, isMobile),
            isMobile: isMobile,
          ),
      ],
    );
  }

  Widget _buildImageGrid(bool isDesktop, bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive grid layout - smaller images since they're clickable
    int crossAxisCount;
    double childAspectRatio;
    double spacing = isDesktop ? 12.0 : (isMobile ? 8.0 : 10.0);
    double borderRadius = isDesktop ? 12.0 : (isMobile ? 8.0 : 10.0);

    if (isDesktop) {
      crossAxisCount = 4; // More columns for smaller images
      childAspectRatio = 0.8; // Slightly more square
    } else if (isMobile) {
      crossAxisCount = 3; // More columns on mobile too
      childAspectRatio = 0.85; // More square for mobile
    } else {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 2 : 4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: widget.project.sliderImages.length,
      itemBuilder: (context, index) {
        final imageUrl = widget.project.sliderImages[index];
        return GestureDetector(
          onTap: () => _openImageInBrowser(imageUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: primaryColor.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.06),
                  blurRadius: isDesktop ? 6 : (isMobile ? 3 : 4),
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: isDesktop ? 3 : (isMobile ? 1 : 2),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                color: Colors.white,
                child: imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[50],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontSize: isMobile ? 9 : 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[50],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: isMobile ? 24.0 : 32.0,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    fontSize: isMobile ? 9 : 11,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[50],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: isMobile ? 24.0 : 32.0,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Image not found',
                                  style: TextStyle(
                                    fontSize: isMobile ? 9 : 11,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
              ),
              child: Icon(
                icon,
                size: isMobile ? 14 : 18,
                color: primaryColor,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 10),
            Text(
              title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 12),
        child,
      ],
    );
  }

  Widget _buildDivider(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isMobile ? 16 : 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : (isDesktop ? 32 : 24)),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: primaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Close Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24, vertical: isMobile ? 8 : 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                side: isMobile
                    ? BorderSide(color: primaryColor.withOpacity(0.3))
                    : BorderSide.none,
              ),
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),

          SizedBox(width: isMobile ? 8 : 16),

          // Open Project Button
          if (widget.project.link != null && widget.project.link!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _openURL(widget.project.link),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 8 : 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                elevation: isMobile ? 2 : 4,
              ),
              icon: Icon(Icons.launch, size: isMobile ? 14 : 20),
              label: Text(
                'Open Project',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
