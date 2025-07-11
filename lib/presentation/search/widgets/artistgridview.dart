import 'package:flutter/material.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/helper_function/routefunc/artistview_route.dart';
import 'package:nex_music/model/artistmodel.dart';

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
        artistViewRoute(
          context,
          artist,
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize * 0.0095,
          vertical: screenSize * 0.0065,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              Expanded(
                child: GridTile(
                  footer: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenSize * 0.0110),
                    color: Colors.black54,
                    alignment: Alignment.center,
                    height: screenSize * 0.0431,
                    child: animatedText(
                      text: artist.artist.name,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ),
                  child: cacheImage(
                    imageUrl: artist.thumbnail,
                    width: double.infinity,
                    height: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
