import 'package:flutter/material.dart';
import 'package:nex_music/core/theme/hexcolor.dart';
import 'package:nex_music/core/ui_component/animatedtext.dart';
import 'package:nex_music/core/ui_component/cacheimage.dart';
import 'package:nex_music/model/artistmodel.dart';
import 'package:nex_music/presentation/search/widgets/chipoptions.dart';

class ArtistInfo extends StatelessWidget {
  final ArtistModel artistModel;
  final double screenSize;
  const ArtistInfo({
    super.key,
    required this.artistModel,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(
          horizontal: screenSize * 0.00263, vertical: screenSize * 0.00659),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          screenSize * 0.0131,
        ),
        color: secondaryColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenSize * 0.0131),
                  bottomLeft: Radius.circular(screenSize * 0.0131),
                ),
                child: cacheImage(
                  imageUrl: artistModel.thumbnail,
                  width: screenSize * 0.240,
                  height: screenSize * 0.245,
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenSize * 0.240,
                    height: screenSize * 0.050,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenSize * 0.0197,
                        vertical: screenSize * 0.00659),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(screenSize * 0.0131),
                      ),
                      color: Colors.black54,
                    ),
                    alignment: Alignment.center,
                    child: animatedText(
                      text: artistModel.artist.name,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                  ))
            ],
          ),
          Column(
            children: [
              ChipOptions(
                label: "Songs",
                onTap: () {},
              ),
              ChipOptions(
                label: "Videos",
                onTap: () {},
              ),
              ChipOptions(
                label: "Playlists",
                onTap: () {},
              ),
              ChipOptions(
                label: "Singles",
                onTap: () {},
              ),
            ],
          ),
          const SizedBox()
        ],
      ),
    );
  }
}
