import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/collapsing_title_sliver_app_bar.dart';

class RecommendationInfoShimmerScreen extends StatefulWidget {
  const RecommendationInfoShimmerScreen({
    super.key,
    this.showStatusCard = false,
    this.showConsentRow = true,
    this.showBackButton = true,
  });

  final bool showStatusCard;

  final bool showConsentRow;

  final bool showBackButton;

  @override
  State<RecommendationInfoShimmerScreen> createState() =>
      _RecommendationInfoShimmerScreenState();
}

class _RecommendationInfoShimmerScreenState
    extends State<RecommendationInfoShimmerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;

    final colors = _ShimmerColors(
      cardBase: Color.alphaBlend(onSurface.withValues(alpha: 0.08), cardColor),
      cardHighlight:
          Color.alphaBlend(onSurface.withValues(alpha: 0.16), cardColor),
      bgBase: Color.alphaBlend(onSurface.withValues(alpha: 0.08), bgColor),
      bgHighlight: Color.alphaBlend(onSurface.withValues(alpha: 0.16), bgColor),
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: _ShimmerScope(
        animation: _controller,
        colors: colors,
        child: Semantics(
          label: 'Loading Recommendations',
          liveRegion: true,
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              CollapsingTitleSliverAppBar(
                title: 'Recommendations',
                backLabel: 'Settings',
                showBackButton: widget.showBackButton,
                onBackTap: widget.showBackButton
                    ? () => Navigator.of(context).pop()
                    : null,
                backgroundColor: bgColor,
              ),
              SliverToBoxAdapter(
                child: ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildHero(),
                        if (widget.showStatusCard) _buildStatusCard(cardColor),
                        // ABOUT
                        const _SectionHeaderBone(width: 56),
                        _GroupedContainer(
                          color: cardColor,
                          children: [
                            const _InfoCardBone(titleWidth: 190, bodyLines: 3),
                            _divider(theme),
                            const _InfoCardBone(titleWidth: 140, bodyLines: 4),
                          ],
                        ),
                        // PERMISSIONS & ACCESS
                        const _SectionHeaderBone(width: 150),
                        _GroupedContainer(
                          color: cardColor,
                          children: [
                            const _InfoCardBone(titleWidth: 160, bodyLines: 4),
                            _divider(theme),
                            const _InfoCardBone(titleWidth: 110, bodyLines: 3),
                          ],
                        ),
                        // PRIVACY & SECURITY
                        const _SectionHeaderBone(width: 130),
                        _GroupedContainer(
                          color: cardColor,
                          children: const [
                            _InfoCardBone(titleWidth: 200, bodyLines: 5),
                          ],
                        ),
                        // YOUR CONTROLS
                        const _SectionHeaderBone(width: 110),
                        _GroupedContainer(
                          color: cardColor,
                          children: [
                            const _InfoCardBone(titleWidth: 100, bodyLines: 2),
                            _divider(theme),
                            const _InfoCardBone(titleWidth: 140, bodyLines: 3),
                            _divider(theme),
                            const _InfoCardBone(titleWidth: 130, bodyLines: 3),
                          ],
                        ),
                        if (widget.showConsentRow) ...[
                          const SizedBox(height: 28),
                          _GroupedContainer(
                            color: cardColor,
                            children: const [_ConsentRowBone()],
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: _Bone(
                            height: 52,
                            radius: 12,
                            onCard: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero skeleton
  Widget _buildHero() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Center(
        child: Column(
          children: [
            _Bone(width: 64, height: 64, radius: 16, onCard: false),
            SizedBox(height: 16),
            _Bone(width: 210, height: 28, radius: 8, onCard: false),
            SizedBox(height: 10),
            _Bone(width: 270, height: 14, radius: 6, onCard: false),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Status card skeleton
  Widget _buildStatusCard(Color cardColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: 26, height: 26, radius: 13),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: 120, height: 16, radius: 6),
                SizedBox(height: 8),
                _Bone(height: 13, radius: 6),
                SizedBox(height: 6),
                _Bone(widthFactor: 0.6, height: 13, radius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) =>
      Divider(height: 1, indent: 60, color: theme.dividerColor);
}

// ─── Building blocks ──────────────────────────────────────────────────────────

class _SectionHeaderBone extends StatelessWidget {
  const _SectionHeaderBone({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8, top: 20),
      child: _Bone(width: width, height: 12, radius: 6, onCard: false),
    );
  }
}

class _GroupedContainer extends StatelessWidget {
  const _GroupedContainer({required this.color, required this.children});
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoCardBone extends StatelessWidget {
  const _InfoCardBone({required this.titleWidth, required this.bodyLines});
  final double titleWidth;
  final int bodyLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Bone(width: 30, height: 30, radius: 6),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bone(width: titleWidth, height: 16, radius: 6),
                const SizedBox(height: 10),
                for (var i = 0; i < bodyLines; i++) ...[
                  if (i > 0) const SizedBox(height: 7),
                  _Bone(
                    widthFactor: i == bodyLines - 1 ? 0.55 : 1,
                    height: 12,
                    radius: 6,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentRowBone extends StatelessWidget {
  const _ConsentRowBone();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Bone(width: 22, height: 22, radius: 6),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(height: 14, radius: 6),
                  SizedBox(height: 8),
                  _Bone(widthFactor: 0.7, height: 14, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Shimmer
class _ShimmerColors {
  const _ShimmerColors({
    required this.cardBase,
    required this.cardHighlight,
    required this.bgBase,
    required this.bgHighlight,
  });
  final Color cardBase;
  final Color cardHighlight;
  final Color bgBase;
  final Color bgHighlight;
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({
    required this.animation,
    required this.colors,
    required super.child,
  });

  final Animation<double> animation;
  final _ShimmerColors colors;

  static _ShimmerScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
    assert(scope != null, '_Bone must be placed inside a _ShimmerScope');
    return scope!;
  }

  @override
  bool updateShouldNotify(_ShimmerScope old) =>
      old.animation != animation || old.colors != colors;
}

class _Bone extends StatelessWidget {
  const _Bone({
    this.width,
    this.widthFactor,
    required this.height,
    this.radius = 8,
    this.onCard = true,
  });

  final double? width;
  final double? widthFactor;
  final double height;
  final double radius;

  final bool onCard;

  @override
  Widget build(BuildContext context) {
    final scope = _ShimmerScope.of(context);
    final base = onCard ? scope.colors.cardBase : scope.colors.bgBase;
    final highlight =
        onCard ? scope.colors.cardHighlight : scope.colors.bgHighlight;
    final screen = MediaQuery.sizeOf(context);
    final animate = !MediaQuery.disableAnimationsOf(context);

    Widget bone = AnimatedBuilder(
      animation: scope.animation,
      builder: (ctx, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final box = ctx.findRenderObject() as RenderBox?;
            if (!animate || box == null || !box.attached || !box.hasSize) {
              return LinearGradient(colors: [base, base]).createShader(bounds);
            }
            final offset = box.localToGlobal(Offset.zero);
            final gradient = LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
              begin: const Alignment(-1, -0.3),
              end: const Alignment(1, 0.3),
              transform: _SlidingGradientTransform(
                slidePercent: -1 + 2 * scope.animation.value,
              ),
            );
            return gradient.createShader(
              Rect.fromLTWH(
                  -offset.dx, -offset.dy, screen.width, screen.height),
            );
          },
          child: child,
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white, // replaced by the shader
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );

    if (widthFactor != null) {
      bone = FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: bone,
      );
    }

    return bone;
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
