import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

Widget cacheImage({
  required imageUrl,
  required double width,
  required double height,
  bool islocal = false,
  bool isRecommendedPlaylist = false,
  String? fallbackUrl,
}) {
  final hasFallback = fallbackUrl != null &&
      fallbackUrl.isNotEmpty &&
      fallbackUrl != imageUrl;

  return islocal
      ? Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            "assets/imageplaceholder.png",
            fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
          ),
        )
      : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
          fadeInDuration:
              hasFallback ? Duration.zero : const Duration(milliseconds: 200),
          fadeOutDuration:
              hasFallback ? Duration.zero : const Duration(milliseconds: 200),
          placeholder: (_, __) => hasFallback
              ? CachedNetworkImage(
                  imageUrl: fallbackUrl,
                  fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  placeholder: (_, __) => Image.asset(
                    "assets/imageplaceholder.png",
                    fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    "assets/imageplaceholder.png",
                    fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  ),
                )
              : Image.asset(
                  "assets/imageplaceholder.png",
                  fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                ),
          errorWidget: (_, __, ___) => hasFallback
              ? CachedNetworkImage(
                  imageUrl: fallbackUrl,
                  fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  placeholder: (_, __) => Image.asset(
                    "assets/imageplaceholder.png",
                    fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    "assets/imageplaceholder.png",
                    fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                  ),
                )
              : Image.asset(
                  "assets/imageplaceholder.png",
                  fit: isRecommendedPlaylist ? BoxFit.fill : BoxFit.cover,
                ),
        );
  // return islocal
  //     ? Image.file(
  //         File(imageUrl),
  //         width: 50,
  //         height: 50,
  //         fit: BoxFit.cover,
  //         errorBuilder: (_, __, ___) => Image.asset(
  //           "assets/imageplaceholder.png",
  //           height: height,
  //           width: width,
  //           fit: BoxFit.fill,
  //         ),
  //       )
  //     : CachedNetworkImage(
  //         imageUrl: imageUrl,
  //         height: height,
  //         width: width,
  //         fit: BoxFit.fill,
  //         placeholder: (_, __) => Image.asset(
  //           "assets/imageplaceholder.png",
  //           height: height,
  //           width: width,
  //           fit: BoxFit.fill,
  //         ),
  //         errorWidget: (_, __, ___) => Image.asset(
  //           "assets/imageplaceholder.png",
  //           height: height,
  //           width: width,
  //           fit: BoxFit.fill,
  //         ),
  //       );

  //===============================================================
}
