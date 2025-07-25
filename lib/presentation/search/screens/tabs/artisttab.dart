import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/search/widgets/artistgridview.dart';

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
          return loadingDisk();
        }
        if (state is ArtistDataState) {
          return state.artists.isEmpty
              ? Center(
                  child: Text(
                    "No artists found.",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                )
              : SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: widget.screenSize * 0.00107,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.artists.length,
                    itemBuilder: (context, index) {
                      final artistData = state.artists[index];
                      return ArtistGridView(
                        artist: artistData,
                      );
                    },
                  ),
                );
        }
        return const SizedBox();
      },
    );
  }
}
