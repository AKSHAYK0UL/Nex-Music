import 'package:flutter/material.dart';

//  THEME CONSTANTS
const Color kPrimary = Color(0xFFE53935);
const Color kBackground = Color(0xFFFFFFFF);
const Color kCardDark = Color(0xFF1A2744);
const Color kTextPrimary = Color(0xFF0D0D0D);
const Color kTextSecondary = Color(0xFF8A8A8A);
const Color kDivider = Color(0xFFEEEEEE);

//  DATA MODELS

class AudiobookModel {
  final String title;
  final String author;
  final String duration;
  final String narrator;
  final double progress; // 0.0 to 1.0, 0 == not started
  final List<Color> gradientColors;
  const AudiobookModel(
    this.title,
    this.author,
    this.duration,
    this.narrator,
    this.progress,
    this.gradientColors,
  );
}

//  SAMPLE DATA

const AudiobookModel currentlyReading = AudiobookModel(
  'Atomic Habits',
  'James Clear',
  '5h 35m',
  'Narrated by James Clear',
  0.45,
  [Color(0xFF8D6E63), Color(0xFF4E342E)],
);

final List<AudiobookModel> myAudiobooks = [
  const AudiobookModel('Atomic Habits', 'James Clear', '5h 35m', 'James Clear',
      0.45, [Color(0xFF8D6E63), Color(0xFF4E342E)]),
  const AudiobookModel('Deep Work', 'Cal Newport', '7h 44m', 'Jeff Bottoms',
      0.0, [Color(0xFF546E7A), Color(0xFF37474F)]),
  const AudiobookModel('The Alchemist', 'Paulo Coelho', '4h 12m',
      'Jeremy Irons', 0.85, [Color(0xFFAD8B5B), Color(0xFF6D4C22)]),
  const AudiobookModel('Sapiens', 'Yuval Noah Harari', '15h 17m',
      'Derek Perkins', 0.0, [Color(0xFF1565C0), Color(0xFF0D47A1)]),
];

final List<AudiobookModel> recommendedBooks = [
  const AudiobookModel('Think and Grow Rich', 'Napoleon Hill', '9h 35m',
      'Napoleon Hill', 0.0, [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
  const AudiobookModel('The Psychology of Money', 'Morgan Housel', '5h 48m',
      'Chris Hill', 0.0, [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
  const AudiobookModel('1984', 'George Orwell', '11h 21m', 'Andrew Wincott',
      0.0, [Color(0xFFB71C1C), Color(0xFF7F0000)]),
  const AudiobookModel('The Power of Now', 'Eckhart Tolle', '7h 37m',
      'Eckhart Tolle', 0.0, [Color(0xFF004D40), Color(0xFF00695C)]),
];

//  AUDIOBOOKS SCREEN 

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});

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
                  child:const  Row(
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
                      'Audiobooks',
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
                        child:const Text(
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
           const SliverToBoxAdapter(
              child: Padding(
                padding:
                     EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _AppSearchBar(hint: 'Find an Audiobook'),
              ),
            ),

            // Currently listening card
          const  SliverToBoxAdapter(
              child: _ContinueListeningCard(book: currentlyReading),
            ),

            // My Audiobooks header
          const  SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'My Audiobooks',
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

            // Audiobooks grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildListDelegate(
                  myAudiobooks.map((b) => _AudiobookGridCard(book: b)).toList(),
                ),
              ),
            ),

            // Recommended header
          const  SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Recommended',
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

            // Recommended list
            SliverList(
              delegate: SliverChildListDelegate(
                recommendedBooks
                    .map((b) => _AudiobookListRow(book: b))
                    .toList(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

//  AUDIOBOOK DETAIL SCREEN 

class AudiobookDetailScreen extends StatefulWidget {
  final AudiobookModel book;
  const AudiobookDetailScreen({super.key, required this.book});

  @override
  State<AudiobookDetailScreen> createState() => _AudiobookDetailScreenState();
}

class _AudiobookDetailScreenState extends State<AudiobookDetailScreen> {
  bool _inLibrary = true;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
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
                      book.gradientColors.first,
                      book.gradientColors.first.withOpacity(0.12),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Book cover
                    Container(
                      width: 130,
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: book.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.menu_book,
                          color: Colors.white, size: 64),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      book.title,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(0.75)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AudiobookPlayerScreen(book: book)),
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              book.progress > 0 ? 'Continue' : 'Play',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _inLibrary = !_inLibrary),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _inLibrary
                            ? kPrimary.withOpacity(0.1)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              _inLibrary ? kPrimary.withOpacity(0.3) : kDivider,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _inLibrary ? Icons.bookmark : Icons.bookmark_border,
                        color: _inLibrary ? kPrimary : kTextSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.download_outlined,
                        color: kTextSecondary, size: 22),
                  ),
                ],
              ),
            ),
          ),

          // Progress bar (if started)
          if (book.progress > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: kDivider,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(book.progress * 100).round()}% complete',
                          style: const TextStyle(
                              color: kPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${book.duration} total',
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Details section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Narrator', value: book.narrator),
                  const Divider(height: 20, color: kDivider),
                  _DetailRow(label: 'Duration', value: book.duration),
                  const Divider(height: 20, color: kDivider),
                  _DetailRow(label: 'Author', value: book.author),
                ],
              ),
            ),
          ),

          // About section
         const SliverToBoxAdapter(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('About',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                   SizedBox(height: 10),
                  Text(
                    'A groundbreaking work about the science and philosophy of '
                    'self-improvement, covering habits, identity, and the '
                    'small changes that lead to remarkable results.',
                    style: TextStyle(
                        color: kTextSecondary, fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

//  AUDIOBOOK PLAYER SCREEN 

class AudiobookPlayerScreen extends StatefulWidget {
  final AudiobookModel book;
  const AudiobookPlayerScreen({super.key, required this.book});

  @override
  State<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends State<AudiobookPlayerScreen> {
  bool _isPlaying = false;
  double _speed = 1.0;
  double _sliderValue = 0.45;

  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: kTextPrimary, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: kTextPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: kTextPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Book cover
            Center(
              child: Container(
                width: 220,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: book.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: book.gradientColors.first.withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.menu_book, color: Colors.white, size: 90),
              ),
            ),
            const SizedBox(height: 32),
            // Title & heart
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(book.author,
                          style: const TextStyle(
                              color: kTextSecondary, fontSize: 15)),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: kPrimary, size: 26),
              ],
            ),
            const SizedBox(height: 24),
            // Progress slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: kTextPrimary,
                inactiveTrackColor: kDivider,
                thumbColor: kTextPrimary,
                overlayColor: Colors.transparent,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v),
              ),
            ),
          const  Padding(
              padding:  EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2h 32m',
                      style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  Text('-2h 45m',
                      style: TextStyle(color: kTextSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 34),
                  color: kTextPrimary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 36),
                  color: kTextPrimary,
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                        color: kTextPrimary, shape: BoxShape.circle),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
                  color: kTextPrimary,
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.forward_30, size: 34),
                  color: kTextPrimary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Speed & extras row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PlayerIconBtn(icon: Icons.bookmark_border, onTap: () {}),
                GestureDetector(
                  onTap: () => _showSpeedSheet(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_speed}x',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: kTextPrimary),
                    ),
                  ),
                ),
                _PlayerIconBtn(icon: Icons.timer_outlined, onTap: () {}),
                _PlayerIconBtn(icon: Icons.list_outlined, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: kDivider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Playback Speed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ..._speeds.map((s) => ListTile(
                  title: Text('${s}x', style: const TextStyle(fontSize: 16)),
                  trailing: _speed == s
                      ? const Icon(Icons.check, color: kPrimary)
                      : null,
                  onTap: () {
                    setState(() => _speed = s);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

//  WIDGETS 

class _ContinueListeningCard extends StatelessWidget {
  final AudiobookModel book;
  const _ContinueListeningCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AudiobookPlayerScreen(book: book)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardDark,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTINUE LISTENING',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Book thumbnail
                Container(
                  width: 70,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: book.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_book,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: book.progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(book.progress * 100).round()}% complete  ·  ${book.duration} total',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      color: kPrimary, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 26),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudiobookGridCard extends StatelessWidget {
  final AudiobookModel book;
  const _AudiobookGridCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AudiobookDetailScreen(book: book)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: book.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.white.withOpacity(0.25),
                        size: 64,
                      ),
                    ),
                    // Progress strip at bottom
                    if (book.progress > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(
                          value: book.progress,
                          backgroundColor: Colors.black38,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            book.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            book.author,
            style: const TextStyle(color: kTextSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (book.progress > 0) ...[
            const SizedBox(height: 3),
            Text(
              '${(book.progress * 100).round()}% complete',
              style: const TextStyle(
                  color: kPrimary, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudiobookListRow extends StatelessWidget {
  final AudiobookModel book;
  const _AudiobookListRow({required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: book.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 26),
            ),
          ),
          title: Text(
            book.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(book.author,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
              Text(book.duration,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
            ],
          ),
          trailing: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AudiobookDetailScreen(book: book)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: kPrimary.withOpacity(0.3), width: 1.2),
              ),
              child: Text(
                'Get',
                style: TextStyle(
                    color: kPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const Divider(height: 1, indent: 86, color: kDivider),
      ],
    );
  }
}

class _PlayerIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PlayerIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 26, color: kTextSecondary),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: kTextSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
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
