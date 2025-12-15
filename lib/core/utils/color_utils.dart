import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final buffer = StringBuffer();
  if (cleaned.length == 6) {
    buffer.write('ff');
  }
  buffer.write(cleaned);
  return Color(int.parse(buffer.toString(), radix: 16));
}

String hexFromColor(Color color) =>
    '#${color.value.toRadixString(16).padLeft(8, '0')}';
