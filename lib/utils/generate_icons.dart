import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// This is a utility class to generate app icons programmatically
class IconGenerator {
  static Future<void> generateIcons() async {
    await _generateAppIcon();
    await _generateSplashIcon();
  }

  static Future<void> _generateAppIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1024, 1024);
    
    // Draw background
    final paint = Paint()
      ..color = const Color(0xFF121212)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Draw a simple task icon
    final iconPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50;
    
    // Draw clipboard outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.width * 0.15, size.width * 0.5, size.height * 0.7),
        const Radius.circular(40),
      ),
      iconPaint,
    );
    
    // Draw clipboard top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.width * 0.05, size.width * 0.2, size.height * 0.1),
        const Radius.circular(20),
      ),
      iconPaint,
    );
    
    // Draw task lines
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.35),
      iconPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.5),
      Offset(size.width * 0.65, size.height * 0.5),
      iconPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.65),
      Offset(size.width * 0.65, size.height * 0.65),
      iconPaint,
    );
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final file = File('assets/images/app_icon.png');
    await file.writeAsBytes(buffer);
    
    print('App icon generated at: ${file.path}');
  }
  
  static Future<void> _generateSplashIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(512, 512);
    
    // Draw a simple task icon (no background)
    final iconPaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25;
    
    // Draw clipboard outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.width * 0.15, size.width * 0.5, size.height * 0.7),
        const Radius.circular(20),
      ),
      iconPaint,
    );
    
    // Draw clipboard top
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.4, size.width * 0.05, size.width * 0.2, size.height * 0.1),
        const Radius.circular(10),
      ),
      iconPaint,
    );
    
    // Draw task lines
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.35),
      Offset(size.width * 0.65, size.height * 0.35),
      iconPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.5),
      Offset(size.width * 0.65, size.height * 0.5),
      iconPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.65),
      Offset(size.width * 0.65, size.height * 0.65),
      iconPaint,
    );
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    
    final file = File('assets/images/splash_icon.png');
    await file.writeAsBytes(buffer);
    
    print('Splash icon generated at: ${file.path}');
  }
}
