import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_music/bloc/connectivity_bloc/bloc/connectivity_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/core/ui_component/global_download_indicator.dart';

import 'package:nex_music/presentation/audio_player/widget/miniplayer.dart';
import 'package:nex_music/presentation/home/navbar/widget/navbarwidget.dart';

class NavBarShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const NavBarShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<NavBarShell> createState() => _NavBarShellState();
}

class _NavBarShellState extends State<NavBarShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectivityBloc>().add(CheckConnectivityStatusEvent());
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SongstreamBloc>().add(UpdateUIEvent());
    }
  }

  void _onTabSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _handleBackButton() {
    if (widget.navigationShell.currentIndex != 0) {
      widget.navigationShell.goBranch(0);
      return false;
    } else {
      SystemNavigator.pop();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: widget.navigationShell,

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MiniPlayer(screenSize: screenSize),
            BlocBuilder<SongstreamBloc, SongstreamState>(
              buildWhen: (previous, current) => previous != current,
              builder: (context, state) {
                if (state is LoadingState ||
                    state is PlayingState ||
                    state is PausedState) {
                  return const SizedBox();
                }
                return const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(0, 0, 0, 0),
                );
              },
            ),
            NavBarWidget(
              screenSize: screenSize,
              selectedIndex: widget.navigationShell.currentIndex,
              onTap: _onTabSelected,
            ),
          ],
        ),
        // : MiniPlayer(screenSize: screenSize),
        floatingActionButton: const GlobalDownloadIndicator(),
      ),
    );
  }
}
