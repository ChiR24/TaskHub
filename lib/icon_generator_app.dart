import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IconGeneratorScreen(),
    );
  }
}

class IconGeneratorScreen extends StatefulWidget {
  @override
  _IconGeneratorScreenState createState() => _IconGeneratorScreenState();
}

class _IconGeneratorScreenState extends State<IconGeneratorScreen> {
  bool _generating = false;
  String _status = 'Ready to generate icons';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icon Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            const SizedBox(height: 20),
            if (_generating) 
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _generateIcons,
                child: const Text('Generate Icons'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateIcons() async {
    setState(() {
      _generating = true;
      _status = 'Generating app icon...';
    });

    try {
      await _generateAppIcon();
      
      setState(() {
        _status = 'Generating splash icon...';
      });
      
      await _generateSplashIcon();
      
      setState(() {
        _status = 'Icons generated successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _generating = false;
      });
    }
  }

  Future<void> _generateAppIcon() async {
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
    
    final directory = Directory('assets/images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    final file = File('assets/images/app_icon.png');
    await file.writeAsBytes(buffer);
    
    print('App icon generated at: ${file.path}');
  }
  
  Future<void> _generateSplashIcon() async {
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
    
    final directory = Directory('assets/images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    final file = File('assets/images/splash_icon.png');
    await file.writeAsBytes(buffer);
    
    print('Splash icon generated at: ${file.path}');
  }
}
