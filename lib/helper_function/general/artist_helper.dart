import 'dart:ui';
import 'package:dart_ytmusic_api/types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/core/route/go_router/go_router.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

// Parses multiple artist names from  raw artist strings.
// Handles delimiters (`,`, `&`, `+`, `/`, `;`, `|`, `•`, ` x `, ` vs `)
// and feature keywords (`feat.`, `featuring`, `ft.`, `with`, `prod by`, `rap by`, etc.).
List<String> parseArtistNames(String raw) {
  if (raw.trim().isEmpty) return [];

  // Normalize brackets () and [] so "(feat. XYZ)" becomes ", feat. XYZ, "
  String normalized = raw
      .replaceAll('(', ', ')
      .replaceAll(')', ', ')
      .replaceAll('[', ', ')
      .replaceAll(']', ', ');

  //  Split on delimiters and collaboration keywords
  final pattern = RegExp(
    r'(?:\s*[,;&+/|\\•]\s*|\s+(?:feat\.?|featuring|ft\.?|with|prod\.?\s+by|produced\s+by|prod\.?|rap\s+by|rap:|vocals?\s+by|vocals?:|music\s+by|composer:|composed\s+by|starring:?|x|vs\.?)\s+)',
    caseSensitive: false,
  );

  final rawTokens = normalized.split(pattern);

  // Pattern for stripping leftover prefixes inside each token
  final prefixPattern = RegExp(
    r'^(?:feat\.?|featuring|ft\.?|with|prod\.?\s+by|produced\s+by|prod\.?|rap\s+by|rap:|vocals?\s+by|vocals?:|music\s+by|x\s+|vs\.?\s+)\s*',
    caseSensitive: false,
  );

  final result = <String>[];
  final seen = <String>{};

  for (var token in rawTokens) {
    token = token.trim();
    token = token.replaceFirst(prefixPattern, '').trim();

    // Remove any punctuation edge noise
    token =
        token.replaceAll(RegExp(r'^[\s,;:\-\./]+|[\s,;:\-\./]+$'), '').trim();

    if (token.isEmpty) continue;
    if (token.length < 2 && !RegExp(r'[a-zA-Z0-9]').hasMatch(token)) continue;

    final lower = token.toLowerCase();
    if (!seen.contains(lower)) {
      seen.add(lower);
      result.add(token);
    }
  }

  // Fallback to trimmed original string if parser left nothing
  if (result.isEmpty && raw.trim().isNotEmpty) {
    return [raw.trim()];
  }

  return result;
}

// Helper to navigate to an artist. If there are multiple artists in [songData.artist.name],
void navigateToArtistOrShowSheet({
  required BuildContext context,
  required Songmodel songData,
  VoidCallback? onBeforeNavigate,
}) {
  showArtistSelectionBottomSheet(
    context: context,
    rawArtistName: songData.artist.name,
    primaryArtistId: songData.artist.artistId,
    onBeforeNavigate: onBeforeNavigate,
  );
}

// Shows  bottom sheet listing all artists from [rawArtistName.
Future<void> showArtistSelectionBottomSheet({
  required BuildContext context,
  required String rawArtistName,
  String? primaryArtistId,
  VoidCallback? onBeforeNavigate,
}) async {
  final artists = parseArtistNames(rawArtistName);
  if (artists.isEmpty) return;

  final repo = context.read<Repository>();
  final router = GoRouter.of(context);

  void doNavigate(String artistName, String? artistId, ArtistModel? cached) {
    if (onBeforeNavigate != null) onBeforeNavigate();
    router.pushNamed(
      RouterName.artistName,
      extra: cached ??
          ArtistModel(
            artist: ArtistBasic(name: artistName, artistId: artistId),
            thumbnail: '',
          ),
    );
  }

  // Single artist: navigate directly
  if (artists.length == 1) {
    final cached = repo.getCachedArtist(primaryArtistId, artists.first);
    doNavigate(artists.first, primaryArtistId, cached);
    return;
  }

  // Multiple artists: display  bottom sheet
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (sheetContext) {
      return _ArtistSelectionSheet(
        artists: artists,
        primaryArtistId: primaryArtistId,
        repo: repo,
        onArtistTap: (artistName, artistId, cached) {
          HapticFeedback.selectionClick();
          Navigator.of(sheetContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            doNavigate(artistName, artistId, cached);
          });
        },
      );
    },
  );
}

// Stateful sheet fetches artist thumbnails asynchronously

class _ArtistSelectionSheet extends StatefulWidget {
  final List<String> artists;
  final String? primaryArtistId;
  final Repository repo;
  final void Function(String name, String? id, ArtistModel? cached) onArtistTap;

  const _ArtistSelectionSheet({
    required this.artists,
    required this.primaryArtistId,
    required this.repo,
    required this.onArtistTap,
  });

  @override
  State<_ArtistSelectionSheet> createState() => _ArtistSelectionSheetState();
}

class _ArtistSelectionSheetState extends State<_ArtistSelectionSheet> {
  late final Map<String, ArtistModel?> _resolved;

  @override
  void initState() {
    super.initState();
    // Pre-populate from cache synchronously
    _resolved = {
      for (int i = 0; i < widget.artists.length; i++)
        widget.artists[i]: widget.repo.getCachedArtist(
          i == 0 ? widget.primaryArtistId : null,
          widget.artists[i],
        ),
    };
    _fetchMissingArtists();
  }

  Future<void> _fetchMissingArtists() async {
    for (int i = 0; i < widget.artists.length; i++) {
      final name = widget.artists[i];
      final existing = _resolved[name];
      if (existing != null && existing.thumbnail.isNotEmpty) continue;

      final artistId = i == 0 ? widget.primaryArtistId : null;
      try {
        final fetched = await widget.repo.resolveArtist(
          ArtistModel(
            artist: ArtistBasic(name: name, artistId: artistId),
            thumbnail: '',
          ),
        );
        if (mounted) {
          setState(() => _resolved[name] = fetched);
        }
      } catch (_) {
        // Keep showing the initial-letter avatar on failure
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          color: isDark
              ? Colors.black.withValues(alpha: 0.88)
              : theme.scaffoldBackgroundColor.withValues(alpha: 0.94),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Artists',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select an artist to view their profile',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(30, 30),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: onSurface.withValues(alpha: 0.08),
                        ),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 14,
                          color: onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Artist List
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.artists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final artistName = widget.artists[index];
                      final isPrimary = index == 0;
                      final artistId =
                          isPrimary ? widget.primaryArtistId : null;
                      final cached = _resolved[artistName];
                      final thumbnail = cached?.thumbnail ?? '';

                      return _ArtistSelectionTile(
                        name: artistName,
                        role: isPrimary ? 'Primary Artist' : 'Featured Artist',
                        thumbnail: thumbnail,
                        isPrimary: isPrimary,
                        onTap: () =>
                            widget.onArtistTap(artistName, artistId, cached),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtistSelectionTile extends StatelessWidget {
  final String name;
  final String role;
  final String thumbnail;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ArtistSelectionTile({
    required this.name,
    required this.role,
    required this.thumbnail,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: isDark ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: isPrimary ? 0.16 : 0.1),
              ),
              child: thumbnail.isNotEmpty
                  ? ClipOval(
                      child: cacheImage(
                        imageUrl: thumbnail,
                        width: 48,
                        height: 48,
                      ),
                    )
                  : Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // Name & Role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isPrimary
                          ? Colors.red
                          : onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}
