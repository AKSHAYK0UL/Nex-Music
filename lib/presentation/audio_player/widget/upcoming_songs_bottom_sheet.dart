import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/upnext_bloc/upnext_bloc.dart';

import 'package:nex_music/enum/tab_route.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/presentation/recent/widgets/recent_song_tile.dart';

class UpcomingSongsBottomSheet extends StatelessWidget {
  const UpcomingSongsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger the event to load upcoming songs
    context.read<UpnextBloc>().add(LoadUpcomingSongsEvent());

    return BlocBuilder<UpnextBloc, UpnextState>(
      builder: (context, state) {
        List<Songmodel> allPlaylistSongs = [];
        int currentSongIndex = -1;
        bool isLoading = false;
        bool shouldShowStartRadio = false;

        if (state is UpnextLoadingState) {
          isLoading = true;
        } else if (state is UpnextLoadedState) {
          allPlaylistSongs = state.allPlaylistSongs;
          currentSongIndex = state.currentSongIndex;
          shouldShowStartRadio = state.shouldShowStartRadio;
          isLoading = state.isRadioLoading;
        } else if (state is UpnextErrorState) {
          return _buildErrorState(context, state.errorMessage);
        }

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7).withValues(alpha: 0.75),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // iOS-style Grab Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Header
                  _buildHeader(context),
                  // Content Area
                  _buildContent(
                    context,
                    allPlaylistSongs: allPlaylistSongs,
                    currentSongIndex: currentSongIndex,
                    isLoading: isLoading,
                    shouldShowStartRadio: shouldShowStartRadio,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Playing Next',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            onPressed: () => context.pop(),
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: Colors.black26,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<Songmodel> allPlaylistSongs,
    required int currentSongIndex,
    required bool isLoading,
    required bool shouldShowStartRadio,
  }) {
    if (allPlaylistSongs.isEmpty) {
      if (isLoading) return _buildLoadingState();
      if (shouldShowStartRadio) return _buildStartRadioButton(context);
      return _buildLoadingState();
    } else {
      return Flexible(
        child: ListView.builder(
          
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: allPlaylistSongs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final songData = allPlaylistSongs[index];
            final isCurrent = index == currentSongIndex;
            final isPlayed = index < currentSongIndex;
            return RecentSongTile(songData: songData, songIndex: index, isCurrent:isCurrent,tabRouteENUM: TabRouteENUM.upNext);
            
            // return _buildUpNextSongTile(context, songData, index, isCurrent, isPlayed);
          },
        ),
      );
    }
  }

  Widget _buildLoadingState() => const Center(child: CupertinoActivityIndicator(radius: 15));

  Widget _buildStartRadioButton(BuildContext context) {
    return Center(
      child: CupertinoButton(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(100),
        onPressed: () {
          final current = context.read<UpnextBloc>().currentSongData;
          if (current != null) context.read<UpnextBloc>().add(StartRadioFromUpnextEvent(videoId: current.vId));
        },
        child: const Text("Start Radio", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String msg) => Center(child: Text(msg));
}

