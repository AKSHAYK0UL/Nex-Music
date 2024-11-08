import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

Widget cacheImage(
    {required imageUrl, required double width, required double height}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    height: height,
    width: width,
    fit: BoxFit.fill,
    placeholder: (_, __) => Image.asset(
      "assets/imageplaceholder.png",
      height: height,
      width: width,
      fit: BoxFit.fill,
    ),
    errorWidget: (_, __, ___) => Image.asset(
      "assets/imageplaceholder.png",
      height: height,
      width: width,
      fit: BoxFit.fill,
    ),
  );
}
