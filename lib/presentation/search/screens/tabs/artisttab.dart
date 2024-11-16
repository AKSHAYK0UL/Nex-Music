import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/presentation/search/widgets/artistInfo.dart';

class ArtistTab extends StatefulWidget {
  final String inputText;
  final double screenSize;
  const ArtistTab({
    super.key,
    required this.inputText,
    required this.screenSize,
  });

  @override
  State<ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
  @override
  void initState() {
    final currentState = context.read<ArtistBloc>().state;
    if (currentState.runtimeType != ArtistDataState) {
      context
          .read<ArtistBloc>()
          .add(GetArtistEvent(inputText: widget.inputText));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ArtistDataState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  right: widget.screenSize * 0.0131,
                  left: widget.screenSize * 0.0131,
                  top: widget.screenSize * 0.0131),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.artists.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final artistData = state.artists[index];
                  return ArtistInfo(
                    artistModel: artistData,
                    screenSize: widget.screenSize,
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
