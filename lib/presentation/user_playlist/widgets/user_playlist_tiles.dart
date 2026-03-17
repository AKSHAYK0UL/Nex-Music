
import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'user_playlist_constants.dart';

// ADD PLAYLIST TILE 

class AddPlaylistTile extends StatelessWidget {
  final VoidCallback onTap;
  const AddPlaylistTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF1A1A2E),
                border: Border.all(
                  color: kPrimary.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background subtle grid pattern
                  CustomPaint(painter: _DotGridPainter()),

                  // Soft radial glow at centre
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            kPrimary.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                kPrimary,
                                kPrimary.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'New Playlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Create a playlist',
            style: TextStyle(
              color: Color(0xFF888899),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Subtle dot-grid background painter for the Add tile
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimary.withOpacity(0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    const radius = 1.2;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// USER PLAYLIST TILE 

class UserPlaylistTile extends StatelessWidget {
  final String playlistName;
  final Color color;
  final String displayMode;
  final List<String> thumbnails;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const UserPlaylistTile({
    super.key,
    required this.playlistName,
    required this.color,
    this.displayMode = 'color',
    this.thumbnails = const [],
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.grey.shade300,
              ),
              child: displayMode == 'dynamic' && thumbnails.isNotEmpty
                  ? _buildDynamicCover()
                  : _buildColorCover(),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            playlistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDynamicCover() {
    final thumbs = List<String?>.generate(
      4,
      (i) => i < thumbnails.length ? thumbnails[i] : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        // Half dimensions — no gap so cells are completely seamless
        final double hw = w / 2;
        final double hh = h / 2;

        return Stack(
          children: [
            // Four seamless quadrants 
            Positioned(
                left: 0,
                top: 0,
                width: hw,
                height: hh,
                child: _gridCell(thumbs[0])),
            Positioned(
                left: hw,
                top: 0,
                width: hw,
                height: hh,
                child: _gridCell(thumbs[1])),
            Positioned(
                left: 0,
                top: hh,
                width: hw,
                height: hh,
                child: _gridCell(thumbs[2])),
            Positioned(
                left: hw,
                top: hh,
                width: hw,
                height: hh,
                child: _gridCell(thumbs[3])),

            // Bottom scrim 
            if (onDelete != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Delete button top-right 
            if (onDelete != null)
              Positioned(
                top: 7,
                right: 7,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  //Single grid cell —fills its Positioned bounds completely.
  Widget _gridCell(String? url) {
    if (url != null && url.isNotEmpty) {
      return SizedBox.expand(
        child: cacheImage(
          imageUrl: url,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return ColoredBox(
      color: Colors.grey.shade400,
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white54, size: 22),
      ),
    );
  }

  //  Colour gradient cover 
  Widget _buildColorCover() {
    final darkShade = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.18).clamp(0.0, 1.0),
        )
        .toColor();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [darkShade, color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Large translucent music note — bottom-right watermark
        Positioned(
          right: -14,
          bottom: -10,
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white.withOpacity(0.10),
            size: 90,
          ),
        ),

        // Second decorative note — top-left, smaller
        Positioned(
          left: -8,
          top: -6,
          child: Icon(
            Icons.music_note_rounded,
            color: Colors.white.withOpacity(0.06),
            size: 54,
          ),
        ),

        // Delete button — top-right
        if (onDelete != null)
          Positioned(
            top: 7,
            right: 7,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }
}
