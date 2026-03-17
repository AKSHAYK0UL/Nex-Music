import 'package:flutter/material.dart';

// THEME CONSTANTS 
const Color kPrimary = Color(0xFFE53935);
const Color kBackground = Color(0xFFFFFFFF);
const Color kCardDark = Color(0xFF1A2744);
const Color kTextPrimary = Color(0xFF0D0D0D);
const Color kTextSecondary = Color(0xFF8A8A8A);
const Color kDivider = Color(0xFFEEEEEE);

//  DATA MODELS 

class PodcastModel {
  final String title;
  final String author;
  final int episodes;
  final List<Color> gradientColors;
  const PodcastModel(
      this.title, this.author, this.episodes, this.gradientColors);
}

class EpisodeModel {
  final String title;
  final String show;
  final String duration;
  final String date;
  final bool isNew;
  final List<Color> gradientColors;
  const EpisodeModel(this.title, this.show, this.duration, this.date,
      this.isNew, this.gradientColors);
}

//  SAMPLE DATA 

final List<PodcastModel> samplePodcasts = [
  const PodcastModel('The Daily', 'New York Times', 365,
      [Color(0xFF1A237E), Color(0xFF283593)]),
  const PodcastModel(
      'How I Built This', 'NPR', 312, [Color(0xFF4A148C), Color(0xFF6A1B9A)]),
  const PodcastModel('Huberman Lab', 'Andrew Huberman', 178,
      [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
  const PodcastModel('Lex Fridman', 'Lex Fridman', 420,
      [Color(0xFF37474F), Color(0xFF455A64)]),
  const PodcastModel('Stuff You Missed', 'iHeartMedia', 890,
      [Color(0xFF880E4F), Color(0xFFAD1457)]),
  const PodcastModel('Crime Junkie', 'audiochuck', 340,
      [Color(0xFF4E342E), Color(0xFF6D4C41)]),
];

final List<EpisodeModel> latestEpisodes = [
  const EpisodeModel(
    'Why Sleep Is Your Superpower',
    'Huberman Lab',
    '1h 22m',
    'Today',
    true,
    [Color(0xFF1B5E20), Color(0xFF2E7D32)],
  ),
  const EpisodeModel(
    "Elon Musk's Vision for Mars",
    'Lex Fridman',
    '3h 15m',
    'Yesterday',
    false,
    [Color(0xFF37474F), Color(0xFF455A64)],
  ),
  const EpisodeModel(
    'The Housing Crisis Explained',
    'The Daily',
    '28m',
    '2 days ago',
    false,
    [Color(0xFF1A237E), Color(0xFF283593)],
  ),
  const EpisodeModel(
    'Sara Blakely: Building Spanx',
    'How I Built This',
    '52m',
    '3 days ago',
    false,
    [Color(0xFF4A148C), Color(0xFF6A1B9A)],
  ),
];

//  PODCASTS SCREEN 

class PodcastsScreen extends StatelessWidget {
  const PodcastsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Back navigation
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children:  [
                      Icon(Icons.chevron_left, color: kPrimary, size: 28),
                      Text('Library',
                          style: TextStyle(color: kPrimary, fontSize: 17)),
                    ],
                  ),
                ),
              ),
            ),

            // Title row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Podcasts',
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: kTextPrimary),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Browse',
                          style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search bar
          const  SliverToBoxAdapter(
              child: Padding(
                padding:
                     EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _AppSearchBar(hint: 'Find a Podcast'),
              ),
            ),

            // Featured banner
            SliverToBoxAdapter(
              child: _FeaturedBanner(),
            ),

            // My Subscriptions header
          const  SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Subscriptions',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            // Subscriptions grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildListDelegate(
                  samplePodcasts
                      .take(4)
                      .map((p) => _PodcastCard(podcast: p))
                      .toList(),
                ),
              ),
            ),

            // Latest Episodes header
          const  SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Episodes',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                          color: kPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            // Episodes list
            SliverList(
              delegate: SliverChildListDelegate(
                latestEpisodes.map((e) => _EpisodeRow(episode: e)).toList(),
              ),
            ),

            // All shows horizontal scroll
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'All Shows',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: samplePodcasts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) =>
                      _PodcastCircle(podcast: samplePodcasts[i]),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

//  PODCAST DETAIL SCREEN 

class PodcastDetailScreen extends StatelessWidget {
  final PodcastModel podcast;
  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: kPrimary, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share_outlined, color: kTextPrimary),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      podcast.gradientColors.first,
                      podcast.gradientColors.first.withOpacity(0.15),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: podcast.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.podcasts,
                          color: Colors.white, size: 56),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      podcast.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast.author,
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(0.75)),
                    ),
                    const SizedBox(height: 16),
                    _SubscribeButton(),
                  ],
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  _StatChip(
                      label: '${podcast.episodes} Episodes',
                      icon: Icons.headphones_outlined),
                  const SizedBox(width: 10),
                  _StatChip(
                      label: 'Weekly', icon: Icons.calendar_today_outlined),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Text(
                'All Episodes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate(
              latestEpisodes.map((e) => _EpisodeRow(episode: e)).toList(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// WIDGETS 

class _FeaturedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PodcastDetailScreen(podcast: samplePodcasts[0])),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        height: 170,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF7B1FA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Daily',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'The New York Times',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow,
                    color: Color(0xFF1A237E), size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodcastCard extends StatelessWidget {
  final PodcastModel podcast;
  const _PodcastCard({required this.podcast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PodcastDetailScreen(podcast: podcast)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: podcast.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        Icons.podcasts,
                        color: Colors.white.withOpacity(0.25),
                        size: 64,
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${podcast.episodes} ep',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            podcast.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            podcast.author,
            style: const TextStyle(color: kTextSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PodcastCircle extends StatelessWidget {
  final PodcastModel podcast;
  const _PodcastCircle({required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: podcast.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.podcasts, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            podcast.title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  final EpisodeModel episode;
  const _EpisodeRow({required this.episode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: episode.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.podcasts, color: Colors.white, size: 28),
            ),
          ),
          title: Row(
            children: [
              if (episode.isNew)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: kPrimary, shape: BoxShape.circle),
                ),
              Expanded(
                child: Text(
                  episode.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Text(episode.show,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 12)),
                const Text(' · ', style: TextStyle(color: kTextSecondary)),
                Text(episode.duration,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 12)),
                const Text(' · ', style: TextStyle(color: kTextSecondary)),
                Text(episode.date,
                    style:
                        const TextStyle(color: kTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          trailing: const Icon(Icons.more_vert, color: kPrimary, size: 20),
        ),
        const Divider(height: 1, indent: 92, color: kDivider),
      ],
    );
  }
}

class _SubscribeButton extends StatefulWidget {
  @override
  State<_SubscribeButton> createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<_SubscribeButton> {
  bool _subscribed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _subscribed = !_subscribed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
        decoration: BoxDecoration(
          color: _subscribed ? Colors.white : kPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _subscribed ? Colors.white54 : kPrimary,
            width: 1.5,
          ),
        ),
        child: Text(
          _subscribed ? '✓  Subscribed' : '+ Subscribe',
          style: TextStyle(
            color: _subscribed ? kPrimary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kTextSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kTextSecondary)),
        ],
      ),
    );
  }
}

class _AppSearchBar extends StatelessWidget {
  final String hint;
  const _AppSearchBar({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, color: kTextSecondary, size: 20),
          const SizedBox(width: 8),
          Text(hint,
              style: const TextStyle(color: kTextSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}
