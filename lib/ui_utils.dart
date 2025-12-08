import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


extension Png on Image {
  static Image name(String name,
      {Key? key,
      double? width,
      double? height,
      double? scale,
      Rect? centerSlice,
      Color? color,
      BoxFit? fit,
      ImageErrorWidgetBuilder? errorBuilder,
      ImageFrameBuilder? frameBuilder}) {
    return Image.asset(
      'assets/images/$name.png',
      key: key,
      width: width,
      height: height,
      scale: scale,
      centerSlice: centerSlice,
      color: color,
      fit: fit ?? BoxFit.cover,
      errorBuilder: errorBuilder,
      frameBuilder: frameBuilder,
    );
  }

  static Image namePlayback(String name,
      {Key? key,
      double? width,
      double? height,
      double? scale,
      Rect? centerSlice,
      Color? color,
      BoxFit? fit,
      ImageErrorWidgetBuilder? errorBuilder}) {
    return Image.asset(
      'assets/images/$name.png',
      key: key,
      width: width,
      height: height,
      scale: scale,
      centerSlice: centerSlice,
      color: color,
      fit: fit ?? BoxFit.cover,
      errorBuilder: errorBuilder,
      gaplessPlayback: true,
    );
  }

}
