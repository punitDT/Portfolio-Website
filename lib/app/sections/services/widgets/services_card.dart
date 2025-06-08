part of '../services.dart';

// Legacy service card - deprecated, keeping for compatibility
class _ServiceCard extends StatefulWidget {
  final dynamic service; // Changed from ServicesUtils to dynamic

  const _ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceCardState createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {},
      onHover: (isHovering) {
        if (isHovering) {
          setState(() => isHover = true);
        } else {
          setState(() => isHover = false);
        }
      },
      child: Container(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.8 // Use 80% of screen width for mobile
            : (Responsive.isTablet(context) ? 400 : null), // Let desktop cards expand to fill available space
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 24.0), // Reduce padding on mobile
        decoration: BoxDecoration(
          gradient: isHover ? modernPurple : theme.serviceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHover ? [glowShadow] : [modernCardShadow],
          border: Border.all(
            color: isHover ? primaryColor.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isHover
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.9),
                          primaryColor.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          whiteColor.withOpacity(0.95),
                          whiteColor.withOpacity(0.85),
                        ],
                      ),
                border: Border.all(
                  color: isHover
                      ? primaryColor.withOpacity(0.8)
                      : primaryColor.withOpacity(0.4),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHover
                        ? primaryColor.withOpacity(0.4)
                        : primaryColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SvgPicture.asset(
                widget.service.icon,
                height: 48,
                color: isHover
                    ? whiteColor
                    : const Color(0xFF1E293B), // Dark color for light background
              ),
            ),
            Space.y(3.w)!,
            Text(
              widget.service.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHover ? whiteColor : theme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Space.y(1.w)!,
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.service.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isHover
                          ? whiteColor.withOpacity(0.9)
                          : theme.textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(), // This pushes the tools to the bottom
                  const SizedBox(height: 16), // Add space before tools section
                  if (Responsive.isDesktop(context))
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.service.tool
                    .map((e) => e.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isHover ? whiteColor : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: isHover
                                          ? whiteColor
                                          : theme.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    .toList(),
                    ),
                  if (Responsive.isMobile(context) || Responsive.isTablet(context))
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.service.tool
                    .map((e) => e.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isHover ? whiteColor : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: isHover
                                          ? whiteColor
                                          : theme.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirestoreServiceCard extends StatefulWidget {
  final ServiceModel service;

  const _FirestoreServiceCard({Key? key, required this.service})
      : super(key: key);

  @override
  _FirestoreServiceCardState createState() => _FirestoreServiceCardState();
}

class _FirestoreServiceCardState extends State<_FirestoreServiceCard> {
  bool isHover = false;

  Widget _buildServiceIcon() {
    final iconUrl = widget.service.iconUrl;
    final theme = Theme.of(context);

    // Use high contrast colors for maximum visibility
    Color iconColor = isHover
        ? whiteColor
        : const Color(0xFF1E293B); // Dark color for light background

    // Handle network URLs (from Firebase Storage or external URLs)
    if (iconUrl.startsWith('http')) {
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        // For network SVG files, we'll use a fallback icon since flutter_svg doesn't support network SVGs easily
        return Icon(
          Icons.build,
          color: iconColor,
          size: 32,
        );
      } else {
        // For network images (PNG, JPG, etc.)
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: whiteColor.withOpacity(0.1),
            ),
            child: Image.network(
              iconUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              headers: const {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
                'Access-Control-Allow-Headers': 'Origin, Content-Type',
              },
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.build,
                color: iconColor,
                size: 32,
              ),
            ),
          ),
        );
      }
    }
    // Handle local asset files
    else if (iconUrl.startsWith('assets/')) {
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        // For local SVG assets
        return SvgPicture.asset(
          iconUrl,
          width: 32,
          height: 32,
          color: iconColor,
        );
      } else {
        // For local image assets
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: whiteColor.withOpacity(0.1),
            ),
            child: Image.asset(
              iconUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.build,
                color: iconColor,
                size: 32,
              ),
            ),
          ),
        );
      }
    }
    // Fallback for any other cases
    else {
      return Icon(
        Icons.build,
        color: iconColor,
        size: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {},
      onHover: (value) {
        setState(() {
          isHover = value;
        });
      },
      child: Container(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.8 // Use 80% of screen width for mobile
            : (Responsive.isTablet(context) ? 400 : null), // Let desktop cards expand to fill available space
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 24.0), // Reduce padding on mobile
        decoration: BoxDecoration(
          gradient: isHover ? modernPurple : theme.serviceCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHover ? [glowShadow] : [modernCardShadow],
          border: Border.all(
            color: isHover ? primaryColor.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isHover
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withOpacity(0.9),
                          primaryColor.withOpacity(0.7),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          whiteColor.withOpacity(0.95),
                          whiteColor.withOpacity(0.85),
                        ],
                      ),
                border: Border.all(
                  color: isHover
                      ? primaryColor.withOpacity(0.8)
                      : primaryColor.withOpacity(0.4),
                  width: Responsive.isMobile(context) ? 2 : 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHover
                        ? primaryColor.withOpacity(0.4)
                        : primaryColor.withOpacity(0.3),
                    blurRadius: Responsive.isMobile(context) ? 12 : 16,
                    offset: const Offset(0, 6),
                    spreadRadius: Responsive.isMobile(context) ? 1 : 2,
                  ),
                ],
              ),
              child: _buildServiceIcon(),
            ),
            SizedBox(height: Responsive.isMobile(context) ? 16 : 24),
            Text(
              widget.service.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHover ? whiteColor : theme.textColor,
                fontSize: Responsive.isMobile(context) ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.isMobile(context) ? 8 : 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.service.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isHover
                          ? whiteColor.withOpacity(0.9)
                          : theme.textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(), // This pushes the tools to the bottom
                  const SizedBox(height: 16), // Add space before tools section
                  if (Responsive.isDesktop(context))
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.service.tools
                    .map((e) => e.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isHover ? whiteColor : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: isHover
                                          ? whiteColor
                                          : theme.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    .toList(),
                    ),
                  if (Responsive.isMobile(context) || Responsive.isTablet(context))
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.service.tools
                    .map((e) => e.isEmpty
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isHover ? whiteColor : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: isHover
                                          ? whiteColor
                                          : theme.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    .toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
