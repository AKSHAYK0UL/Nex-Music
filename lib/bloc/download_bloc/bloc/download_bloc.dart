import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nex_music/enum/quality.dart';
import 'package:nex_music/model/songmodel.dart';
import 'package:nex_music/repository/downlaod_repository/download_repository.dart';
import 'package:nex_music/repository/home_repo/repository.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final Repository _repository;
  final DownloadRepo _downloadRepo;

  DownloadBloc(this._repository, this._downloadRepo)
      : super(DownloadInitial()) {
    on<DownloadSongEvent>(_downloadSong);
  }

  Future<void> _downloadSong(
      DownloadSongEvent event, Emitter<DownloadState> emit) async {
    try {
      final url =
          await _repository.getSongUrl(event.songData.vId, AudioQuality.high);
      final path = _downloadRepo.downloadSong(url.toString(), event.songData);
      print("SONG DOWNLOAD STARTED @@@");

      print("SONG PATH $path @@@");
    } catch (e) {
      print("SONG ERROR ${e.toString()} @@@");
    }
  }
}
