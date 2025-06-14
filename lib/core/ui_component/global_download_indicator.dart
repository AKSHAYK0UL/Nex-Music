import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/download_bloc/bloc/download_bloc.dart';
import 'package:nex_music/bloc/offline_songs_bloc/bloc/offline_songs_bloc.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/snackbar.dart';

class GlobalDownloadIndicator extends StatelessWidget {
  const GlobalDownloadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is DownloadCompletedState) {
          context.read<OfflineSongsBloc>().add(LoadOfflineSongsEvent());
        }
        if (state is DownloadPercantageStatusState) {
          return SizedBox(
            height: 70,
            width: 70,
            child: FloatingActionButton(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(color: backgroundColor)),
              onPressed: () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 56, // slightly less than FAB size
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(state.songData.thumbnail),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  StreamBuilder<double>(
                    stream: state.percentageStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: accentColor,
                        );
                      }
                      if (snapshot.hasError) {
                        showSnackbar(context, "Error in Downloading");
                      }
                      return CircularProgressIndicator(
                        color: accentColor,
                        backgroundColor: secondaryColor,
                        // strokeAlign: 7.2,
                        strokeAlign: 9.0,

                        strokeWidth: 3,
                        value: snapshot.data! / 100,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
