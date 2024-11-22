import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fullartistalbum_event.dart';
part 'fullartistalbum_state.dart';

class FullArtistAlbumBloc
    extends Bloc<FullArtistAlbumBloc, FullArtistAlbumState> {
  FullArtistAlbumBloc() : super(FullartistalbumInitial()) {}
}
