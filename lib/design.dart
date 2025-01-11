import "package:flutter/material.dart";

class Looks {
  // Padding set for general use screens for aesthetic. Ideally set to every screen
  static const pagePadding = EdgeInsets.fromLTRB(25, 15, 25, 35);

  // Text styles
  static const textColor = Colors.black;
  static const headerStyle = TextStyle(
    fontSize: 24,
    color: textColor,
    fontWeight: FontWeight.bold,
  );
  static const subHeadStyle = TextStyle(
    fontSize: 14,
    color: textColor,
    fontWeight: FontWeight.w400,
  );
  static const captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}
