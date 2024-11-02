import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final repositoryProvider = RepositoryProvider(
  create: (context) => Repository(
    dataProvider: DataProvider(
      ytMusic: YTMusic(),
      youtubeExplode: YoutubeExplode(),
    ),
    yt: YoutubeExplode(),
  ),
);
