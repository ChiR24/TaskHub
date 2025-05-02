import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mini_taskhub/app/theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitDoubleBounce(
        color: color ?? AppTheme.primaryColor,
        size: size,
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color? color;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingIndicator(
              color: color ?? Colors.white,
            ),
          ),
      ],
    );
  }
}
