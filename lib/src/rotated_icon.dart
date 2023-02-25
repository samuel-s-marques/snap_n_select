import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class RotatedIcon extends StatefulWidget {
  const RotatedIcon(this.icon, {super.key, this.turningSpeed});

  final Icon icon;
  final Duration? turningSpeed;

  @override
  State<RotatedIcon> createState() => _RotatedIconState();
}

class _RotatedIconState extends State<RotatedIcon> {
  double turns = 0;

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: true,
      builder: (BuildContext context) {
        final NativeDeviceOrientation orientation = NativeDeviceOrientationReader.orientation(context);

        switch (orientation) {
          case NativeDeviceOrientation.portraitUp:
            turns = 0;
            break;
          case NativeDeviceOrientation.portraitDown:
            turns = 1.0 / 2.0;
            break;
          case NativeDeviceOrientation.landscapeLeft:
            turns = 1.0 / 4.0;
            break;
          case NativeDeviceOrientation.landscapeRight:
            turns = -(1.0 / 4.0);
            break;
          case NativeDeviceOrientation.unknown:
            turns = 0;
            break;
        }

        return AnimatedRotation(
          turns: turns,
          duration: widget.turningSpeed ?? const Duration(milliseconds: 100),
          child: widget.icon,
        );
      },
    );
  }
}
