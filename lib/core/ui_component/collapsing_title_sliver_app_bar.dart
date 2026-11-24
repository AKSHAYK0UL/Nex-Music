import 'package:flutter/material.dart';

class CollapsingTitleSliverAppBar extends StatelessWidget {
  final String title;
  final String backLabel;
  final VoidCallback? onBackTap;
  final bool showBackButton;
  final double expandedBarHeight;
  final double bigTitleFontSize;
  final double smallTitleFontSize;
  final Color? backgroundColor;

  const CollapsingTitleSliverAppBar({
    super.key,
    required this.title,
    this.backLabel = 'Settings',
    this.onBackTap,
    this.showBackButton = true,
    this.expandedBarHeight = 110.0,
    this.bigTitleFontSize = 30.0,
    this.smallTitleFontSize = 17.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    return SliverAppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      stretch: true,
      expandedHeight: expandedBarHeight,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final double minHeight = kToolbarHeight + statusBarHeight;

          // Calculate ratios for animations
          // 1.0 = fully expanded, 0.0 = fully collapsed
          final double expandRatio =
              ((top - minHeight) / (expandedBarHeight - kToolbarHeight))
                  .clamp(0.0, 1.0);
          final double collapseRatio = 1.0 - expandRatio;

          return Stack(
            children: [
              // BIG TITLE (Bottom Left - Fades out on collapse)

              Positioned(
                left: 16,
                right: 16,
                bottom: 10,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: expandRatio,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: bigTitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // SMALL TITLE (Fades in on collapse, taking the place of the back label)
              Positioned(
                left: 0,
                right: 16,
                top: statusBarHeight,
                height: kToolbarHeight,
                child: IgnorePointer(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: showBackButton ? 40 : 16),
                    child: Opacity(
                      // Starts fading in after 80% of the scroll is done
                      opacity: collapseRatio > 0.8
                          ? (collapseRatio - 0.8) / 0.2
                          : 0.0,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: smallTitleFontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // STATIC BACK BUTTON (Placed last so it is on top of all title layers for hit testing)
              if (showBackButton)
                Positioned(
                  left: 0,
                  top: statusBarHeight,
                  height: kToolbarHeight,
                  child: GestureDetector(
                    onTap: onBackTap ?? () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.transparent,
                      constraints: const BoxConstraints(minWidth: 60),
                      padding: const EdgeInsets.only(left: 8, right: 12),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Opacity(
                            opacity: expandRatio,
                            child: Text(
                              backLabel,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
