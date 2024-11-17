import 'package:nex_music/model/songmodel.dart';

List<Songmodel> updateRecentPlayedList(
    List<Songmodel> recent, Songmodel newSong) {
  int isExistIndex = recent.indexWhere((rP) => rP == newSong);
  if (isExistIndex > -1) {
    recent.removeAt(isExistIndex);
  }
  recent.add(newSong);
  return recent;
}
