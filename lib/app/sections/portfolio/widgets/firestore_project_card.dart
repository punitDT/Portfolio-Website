import 'package:flutter/material.dart';
import 'package:mysite/core/models/project_model.dart';
import 'package:mysite/core/res/responsive.dart';

import 'package:mysite/core/color/colors.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class FirestoreProjectCard extends StatefulWidget {
  final ProjectModel project;
  const FirestoreProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  State<FirestoreProjectCard> createState() => _FirestoreProjectCardState();
}

class _FirestoreProjectCardState extends State<FirestoreProjectCard> {
  bool isHover = false;

  void _openURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print('Could not launch $url');
        }
      } catch (e) {
        print('Error opening URL: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _openURL(widget.project.link),
      onHover: (isHovering) {
        setState(() => isHover = isHovering);
      },
      child: Container(
        width: Responsive.isDesktop(context) ? 30.w :
               Responsive.isTablet(context) ? 60.w : 80.w, // Reduced mobile width to prevent overflow
        height: Responsive.isDesktop(context) ? 36.h :
                Responsive.isTablet(context) ? 32.h : 28.h, // Responsive height
        clipBehavior: Clip.none, // Prevent clipping of content
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: isHover ? [glowShadow] : [modernCardShadow],
          border: Border.all(
            color: isHover ? primaryColor.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image as background
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
                              child: Icon(Icons.web_asset, size: 50, color: Colors.white),
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
                              child: Icon(Icons.web_asset, size: 50, color: Colors.white),
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

              // Overlay with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isHover ? primaryColor.withOpacity(0.9) : Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // Content overlay
              Padding(
                padding: EdgeInsets.all(Responsive.isDesktop(context) ? 20 : 16), // Responsive padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    if (widget.project.iconUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.project.iconUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.project.iconUrl,
                                height: 24,
                                width: 24,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.web_asset, size: 24),
                              )
                            : Image.asset(
                                widget.project.iconUrl,
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.web_asset, size: 24),
                              ),
                      ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      widget.project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      widget.project.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
