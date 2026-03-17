
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/user_playlist_constants.dart';

class CreatePlaylistScreen extends StatefulWidget {
  final Function({
    required String name,
    required String description,
    required int colorValue,
    required String displayMode,
    required bool isPublic,
  }) onCreate;

  final String backLabel;

  const CreatePlaylistScreen({
    super.key,
    required this.onCreate,
    this.backLabel = 'Playlist',
  });

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _nameFocus = FocusNode();
  Color _selectedColor = kPrimary;
  bool _isPublic = false;
  String _displayMode = 'color';

  final List<Color> _colorOptions = [
    kPrimary,
    const Color(0xFF6A1B9A),
    const Color(0xFF1565C0),
    const Color(0xFF2E7D32),
    const Color(0xFFE65100),
    const Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  bool get _canCreate => _nameController.text.trim().isNotEmpty;

  void _handleCreate() {
    if (_canCreate) {
      widget.onCreate(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        colorValue: _selectedColor.value,
        displayMode: _displayMode,
        isPublic: _isPublic,
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double expandedBarHeight = 110.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          //  Sliver App Bar 
          SliverAppBar(
            backgroundColor: Colors.white,
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
                final double expandRatio =
                    ((top - minHeight) / (expandedBarHeight - kToolbarHeight))
                        .clamp(0.0, 1.0);
                final double collapseRatio = 1.0 - expandRatio;

                return Stack(
                  children: [
                    //  Back arrow + "Playlist" label
                    Positioned(
                      left: 8,
                      top: statusBarHeight,
                      height: kToolbarHeight,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                           const Icon(Icons.arrow_back_ios_new,
                                color: kPrimary, size: 20),
                            const SizedBox(width: 4),
                            Opacity(
                              opacity: expandRatio,
                              child: Text(
                                widget.backLabel,
                                style: const TextStyle(color: kPrimary, fontSize: 17),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2Small collapsed title (fades in after 80% scroll)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: statusBarHeight,
                      height: kToolbarHeight,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 40),
                        child: Opacity(
                          opacity: collapseRatio > 0.8
                              ? (collapseRatio - 0.8) / 0.2
                              : 0.0,
                          child: const Text(
                            'Create Playlist',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    //  Big expanded title — bottom left
                    Positioned(
                      left: 20,
                      bottom: 12,
                      child: Opacity(
                        opacity: expandRatio,
                        child: const Text(
                          'Create Playlist',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 28,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ),
                    ),

                    // 4. "Create" action — top right
                    // Positioned(
                    //   right: 8,
                    //   top: statusBarHeight,
                    //   height: kToolbarHeight,
                    //   child: Center(
                    //     child: TextButton(
                    //       onPressed: _canCreate ? _handleCreate : null,
                    //       style: TextButton.styleFrom(
                    //         backgroundColor: _canCreate
                    //             ? kPrimary.withOpacity(0.1)
                    //             : Colors.transparent,
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8)),
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 14, vertical: 6),
                    //       ),
                    //       child: Text(
                    //         'Create',
                    //         style: TextStyle(
                    //           color: _canCreate ? kPrimary : kTextSecondary,
                    //           fontSize: 15,
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            ),
          ),

          //  Body content 
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover preview
                  Center(child: _buildCoverPreview()),
                  // const SizedBox(height: 8),
                  // Center(
                  //   child: TextButton.icon(
                  //     onPressed: () {},
                  //     icon:const Icon(Icons.add_photo_alternate_outlined,
                  //         color: kPrimary, size: 16),
                  //     label:const Text(
                  //       'Add Cover Photo',
                  //       style: TextStyle(
                  //         color: kPrimary,
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: 13,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 30),

                  // Name
                  const _FieldLabel('PLAYLIST NAME'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    hint: 'e.g. My Favourites',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  const _FieldLabel('DESCRIPTION'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _descController,
                    hint: 'Optional description...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),

                  // Cover style
                  const _FieldLabel('COVER STYLE'),
                  const SizedBox(height: 10),
                  _buildDisplayModePicker(),
                  const SizedBox(height: 22),

                  // Color picker
                  if (_displayMode == 'color') ...[
                    const _FieldLabel('PLAYLIST COLOR'),
                    const SizedBox(height: 12),
                    _buildColorPicker(),
                    const SizedBox(height: 22),
                  ],

                  // Privacy
                  _buildPrivacyToggle(),
                  const SizedBox(height: 28),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _canCreate
                            ? [
                                BoxShadow(
                                  color: kPrimary.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: _canCreate ? _handleCreate : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          disabledBackgroundColor: const Color(0xFFE0E0E0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Playlist',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _canCreate ? Colors.white : kTextSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cover preview 
  Widget _buildCoverPreview() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_displayMode == 'color' ? _selectedColor : Colors.black)
                .withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _displayMode == 'dynamic'
            ? _buildDynamicPreview()
            : _buildColorPreview(),
      ),
    );
  }

  Widget _buildDynamicPreview() {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final cw = (w - 2) / 2;
      final ch = (h - 2) / 2;
      final List<Color> shades = [
        Colors.grey.shade300,
        Colors.grey.shade400,
        Colors.grey.shade400,
        Colors.grey.shade300,
      ];
      return Stack(children: [
        Positioned(
            left: 0,
            top: 0,
            width: cw,
            height: ch,
            child: _previewCell(shades[0])),
        Positioned(
            left: cw + 2,
            top: 0,
            width: cw,
            height: ch,
            child: _previewCell(shades[1])),
        Positioned(
            left: 0,
            top: ch + 2,
            width: cw,
            height: ch,
            child: _previewCell(shades[2])),
        Positioned(
            left: cw + 2,
            top: ch + 2,
            width: cw,
            height: ch,
            child: _previewCell(shades[3])),
      ]);
    });
  }

  Widget _previewCell(Color shade) => ColoredBox(
        color: shade,
        child: Center(
          child: Icon(Icons.music_note_rounded,
              color: Colors.white.withOpacity(0.5), size: 22),
        ),
      );

  Widget _buildColorPreview() {
    final dark = HSLColor.fromColor(_selectedColor)
        .withLightness((HSLColor.fromColor(_selectedColor).lightness - 0.18)
            .clamp(0.0, 1.0))
        .toColor();
    return Stack(fit: StackFit.expand, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [dark, _selectedColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      Positioned(
        right: -10,
        bottom: -8,
        child: Icon(Icons.music_note_rounded,
            color: Colors.white.withOpacity(0.12), size: 80),
      ),
      const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white70, size: 52),
      ),
    ]);
  }

  // Display mode picker 
  Widget _buildDisplayModePicker() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ModeTab(
            icon: Icons.palette_outlined,
            label: 'Color',
            isActive: _displayMode == 'color',
            onTap: () => setState(() => _displayMode = 'color'),
          ),
          _ModeTab(
            icon: Icons.grid_view_rounded,
            label: 'Dynamic',
            isActive: _displayMode == 'dynamic',
            onTap: () => setState(() => _displayMode = 'dynamic'),
          ),
        ],
      ),
    );
  }

  // Color picker 
  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _colorOptions.map((c) {
        final isSelected = _selectedColor == c;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 42 : 36,
            height: isSelected ? 42 : 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: c.withOpacity(0.55),
                          blurRadius: 12,
                          spreadRadius: 1)
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // Privacy toggle  CupertinoSwitch 
  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Animated icon badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _isPublic
                  ? const Color(0xFF22C55E).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
              color: _isPublic ? const Color(0xFF22C55E) : kTextSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Animated labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isPublic ? 'Public Playlist' : 'Private Playlist',
                    key: ValueKey(_isPublic),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isPublic
                        ? 'Anyone can find and play'
                        : 'Only you can see this',
                    key: ValueKey('sub_$_isPublic'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //  CupertinoSwitch (green active) 
          CupertinoSwitch(
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
            activeTrackColor : const Color(0xFF22C55E),
            inactiveTrackColor : const Color(0xFFD1D5DB),
            thumbColor: const CupertinoDynamicColor.withBrightness(
              color: Colors.white,
              darkColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Mode tab 
class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: isActive ? kPrimary : kTextSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? kTextPrimary : kTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Field label 
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kTextSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// Input field 
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    this.focusNode,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLines: maxLines,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        cursorColor: kPrimary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: kTextSecondary.withOpacity(0.7),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
