import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/bloc/homesection_bloc/homesection_bloc.dart';
import 'package:nex_music/bloc/playlist_bloc/playlist_bloc.dart';
import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

List<BlocProvider> blocProviders() {
  return [
    BlocProvider(
      create: (context) => HomesectionBloc(context.read<Repository>()),
    ),
    BlocProvider(
      create: (context) => PlaylistBloc(context.read<Repository>()),
    ),
    BlocProvider(
      create: (context) => SongstreamBloc(context.read<Repository>()),
    ),
  ];
}
