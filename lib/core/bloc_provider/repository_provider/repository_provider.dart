import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/enum/collection_enum.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RepositoryProviderClass {
  static final repositoryProvider = RepositoryProvider(
    create: (context) => Repository(
      dataProvider: DataProvider(
        ytMusic: YTMusic(),
        youtubeExplode: YoutubeExplode(),
      ),
      yt: YoutubeExplode(),
    ),
  );
  static final dbRepositoryProvider = RepositoryProvider(
    create: (context) => DbRepository(
      DbNetworkProvider(
        firestoreInstance: FirebaseFirestore.instance,
        userId: "123",
        collections: {
          CollectionEnum.recentPlayed: "recentPlayed",
        },
      ),
    ),
  );
}
