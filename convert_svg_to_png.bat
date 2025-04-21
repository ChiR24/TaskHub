@echo off
echo Converting SVG files to PNG...

REM Install required packages
call flutter pub add flutter_svg
call flutter pub add path_provider

REM Create a temporary Dart file to convert SVG to PNG
echo import 'dart:io'; > convert_svg.dart
echo import 'dart:ui' as ui; >> convert_svg.dart
echo import 'package:flutter/material.dart'; >> convert_svg.dart
echo import 'package:flutter/services.dart'; >> convert_svg.dart
echo import 'package:flutter_svg/flutter_svg.dart'; >> convert_svg.dart
echo void main() async { >> convert_svg.dart
echo   WidgetsFlutterBinding.ensureInitialized(); >> convert_svg.dart
echo   final appIconBytes = await File('assets/images/app_icon.svg').readAsBytes(); >> convert_svg.dart
echo   final splashIconBytes = await File('assets/images/splash_icon.svg').readAsBytes(); >> convert_svg.dart
echo   final appIconPicture = await vg.loadPicture(SvgBytesLoader(appIconBytes), null); >> convert_svg.dart
echo   final splashIconPicture = await vg.loadPicture(SvgBytesLoader(splashIconBytes), null); >> convert_svg.dart
echo   final appIconImage = await appIconPicture.toImage(1024, 1024); >> convert_svg.dart
echo   final splashIconImage = await splashIconPicture.toImage(512, 512); >> convert_svg.dart
echo   final appIconByteData = await appIconImage.toByteData(format: ui.ImageByteFormat.png); >> convert_svg.dart
echo   final splashIconByteData = await splashIconImage.toByteData(format: ui.ImageByteFormat.png); >> convert_svg.dart
echo   await File('assets/images/app_icon.png').writeAsBytes(appIconByteData!.buffer.asUint8List()); >> convert_svg.dart
echo   await File('assets/images/splash_icon.png').writeAsBytes(splashIconByteData!.buffer.asUint8List()); >> convert_svg.dart
echo   print('Conversion complete!'); >> convert_svg.dart
echo } >> convert_svg.dart

REM Run the conversion script
call flutter run -d windows convert_svg.dart

REM Clean up
del convert_svg.dart

echo Conversion complete!
pause
