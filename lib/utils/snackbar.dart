import 'package:flutter/material.dart';

showSnackBar(String message, BuildContext parentContext,
    {Color? backgroundColor, Duration? duration}) {
  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
    content: Text(
      message,
      style: TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
    ),
    backgroundColor: backgroundColor ?? Colors.black54,
    duration: duration ?? Duration(milliseconds: 2000),
  ));
}
