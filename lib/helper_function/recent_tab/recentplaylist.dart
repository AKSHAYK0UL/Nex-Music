import 'package:nex_music/model/songmodel.dart';

List<Songmodel> updateRecentPlayedList(
    List<Songmodel> recent, Songmodel newSong) {
  if (recent.contains(newSong)) {
    recent.remove(newSong);
  }
  recent.add(newSong);
  return recent;
}
