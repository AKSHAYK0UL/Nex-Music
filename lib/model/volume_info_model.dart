import 'package:nex_music/bloc/songstream_bloc/bloc/songstream_bloc.dart';

class VolumeInfoModel {
  final double volume;
  final bool isMuted;

  const VolumeInfoModel({
    required this.volume,
    required this.isMuted,
  });

  factory VolumeInfoModel.fromState(SongstreamState state) {
    if (state is PlayingState) {
      return VolumeInfoModel(
        volume: state.volume,
        isMuted: state.isMuted,
      );
    } else if (state is PausedState) {
      return VolumeInfoModel(
        volume: state.volume,
        isMuted: state.isMuted,
      );
    } else if (state is LoadingState) {
      return VolumeInfoModel(
        volume: state.volume,
        isMuted: state.isMuted,
      );
    }
    // Default values
    return const VolumeInfoModel(
      volume: 0.5,
      isMuted: false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VolumeInfoModel &&
        other.volume == volume &&
        other.isMuted == isMuted;
  }

  @override
  int get hashCode => volume.hashCode ^ isMuted.hashCode;
}
