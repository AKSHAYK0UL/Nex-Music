import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nex_music/core/services/hive_singleton.dart';
import 'package:nex_music/network_provider/home_data/auth_provider.dart';
import 'package:nex_music/network_provider/home_data/dataprovider.dart';
import 'package:nex_music/network_provider/home_data/db_network_provider.dart';
import 'package:nex_music/network_provider/home_data/favorites_db_provider.dart';
import 'package:nex_music/network_provider/home_data/playlist_db_provide.dart';
import 'package:nex_music/repository/auth_repository/auth_repository.dart';
import 'package:nex_music/repository/db_repository/db_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RepositoryProviderClass {
  final FirebaseAuth firebaseAuthInstance;
  final Connectivity connectivity;
  final FirebaseFirestore firebaseFirestore;

  RepositoryProviderClass(
      {required this.firebaseAuthInstance,
      required this.connectivity,
      required this.firebaseFirestore});

  // Getter for FirebaseInstance
  FirebaseAuth get getFirebaseAuthInstance {
    return firebaseAuthInstance;
  }

  //Getter for Connectivity
  Connectivity get getConnectivityInstance {
    return connectivity;
  }

  // Getter for RepositoryProvider
  RepositoryProvider<Repository> get repositoryProvider => RepositoryProvider(
        create: (context) => Repository(
          dataProvider: DataProvider(
            ytMusic: YTMusic(),
            youtubeExplode: YoutubeExplode(),
          ),
          yt: YoutubeExplode(),
          dbInstance: HiveDataBaseSingleton.instance,
        ),
      );

  // Getter for DbRepositoryProvider
  RepositoryProvider<DbRepository> get dbRepositoryProvider =>
      RepositoryProvider(
        create: (context) => DbRepository(
          dbDataProvider: DbNetworkProvider(
            // firestoreInstance: FirebaseFirestore.instance,
            firestoreInstance: firebaseFirestore,
            userId: firebaseAuthInstance.currentUser!.uid,
            // collections: {
            //   CollectionEnum.recentPlayed: "recentPlayed",
            // },
          ),
          favoritesDBProvider: FavoritesDBProvider(
            firestoreInstance: firebaseFirestore,
            userId: firebaseAuthInstance.currentUser!.uid,
          ),
          playlistDbProvider: PlaylistDbProvider(
            firestoreInstance: firebaseFirestore,
            userId: firebaseAuthInstance.currentUser!.uid,
          ),
        ),
      );

  // Getter for AuthRepositoryProvider
  RepositoryProvider<AuthRepository> get authRepositoryProvider =>
      RepositoryProvider(
        create: (context) => AuthRepository(
          AuthProviderr(firebaseAuthInstance),
          GoogleSignIn(),
        ),
      );
}
