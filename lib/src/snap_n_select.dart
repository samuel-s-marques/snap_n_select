import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snap_n_select/src/rotated_icon.dart';

class SnapNSelect extends StatefulWidget {
  const SnapNSelect({
    super.key,
    this.customAppBar,
    this.customBottomBar,
    this.showGalleryIcon = true,
    this.showFlashIcon = true,
    this.showCameraSwitchIcon = true,
  });

  final PreferredSizeWidget? customAppBar;
  final Widget? customBottomBar;
  final bool showGalleryIcon;
  final bool showFlashIcon;
  final bool showCameraSwitchIcon;

  @override
  State<SnapNSelect> createState() => _SnapNSelectState();
}

class _SnapNSelectState extends State<SnapNSelect> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: widget.customAppBar ??
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {},
              icon: const RotatedIcon(
                Icon(Icons.close),
              ),
            ),
            actions: [
              if (widget.showFlashIcon)
                IconButton(
                  onPressed: () {},
                  icon: const RotatedIcon(
                    Icon(
                      Icons.flash_off,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
      body: Column(
        children: [
          // TODO: Add camera as background
          Expanded(
            // TODO: Replace with GridView
            child: ListView(
              shrinkWrap: true,
              children: [],
            ),
          ),

          if (widget.customBottomBar != null)
            widget.customBottomBar!
          else
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.showGalleryIcon)
                    IconButton(
                      // TODO: Add functionality
                      onPressed: () {},
                      // TODO: Change icon
                      icon: const RotatedIcon(
                        Icon(Icons.folder_copy),
                      ),
                    ),
                  if (widget.showCameraSwitchIcon)
                    IconButton(
                      // TODO: Add functionality
                      onPressed: () {},
                      // TODO: Change icon
                      icon: const RotatedIcon(
                        Icon(Icons.cameraswitch),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
