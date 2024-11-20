import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/home/artist/artist_full.dart';

class ArtistGridView extends StatelessWidget {
  final ArtistModel artist;
  const ArtistGridView({
    super.key,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ArtistFullScreen.routeName, arguments: artist);
      },
      child: Container(
        height: screenSize * 0.237,
        width: screenSize * 0.240,
        margin: EdgeInsets.symmetric(
            horizontal: screenSize * 0.0100, vertical: screenSize * 0.0070),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenSize * 0.0132),
          child: Column(
            children: [
              cacheImage(
                imageUrl: artist.thumbnail,
                width: screenSize * 0.240,
                height: screenSize * 0.238,
              ),
              SizedBox(
                height: screenSize * 0.0050,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenSize * 0.0220),
                child: animatedText(
                  text: artist.artist.name,
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
