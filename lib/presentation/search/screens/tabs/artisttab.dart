import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/artist_bloc/bloc/artist_bloc.dart';
import 'package:nex_music/core/ui_component/loading_disk.dart';
import 'package:nex_music/presentation/search/widgets/artistgridview.dart';

class ArtistTab extends StatefulWidget {
  final String inputText;
  final double screenSize;
  const ArtistTab(
      {super.key, required this.inputText, required this.screenSize});

  @override
  State<ArtistTab> createState() => _ArtistTabState();
}

class _ArtistTabState extends State<ArtistTab> {
  @override
  void initState() {
    super.initState();
    // Only trigger search if  don't already have results for this search
    final currentState = context.read<ArtistBloc>().state;
    if (currentState.runtimeType != ArtistDataState) {
      context
          .read<ArtistBloc>()
          .add(GetArtistEvent(inputText: widget.inputText));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArtistBloc, ArtistState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is LoadingState) return loadingDisk();
        if (state is ArtistDataState) {
          if (state.artists.isEmpty)
            return _buildEmptyState("No artists found");

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.8,
            ),
            itemCount: state.artists.length,
            itemBuilder: (context, index) {
              return ArtistGridView(artist: state.artists[index]);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message,
          style: const TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}
