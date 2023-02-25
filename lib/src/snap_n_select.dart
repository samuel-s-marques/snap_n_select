import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snap_n_select/src/rotated_icon.dart';

class SnapNSelect extends StatefulWidget {
  const SnapNSelect({
    super.key,
    this.customAppBar,
    this.customBottomBar,
    this.closeIcon,
    this.flashIcon,
    this.cameraSwitchIcon,
    this.galleryIcon,
    this.showCloseIcon = true,
    this.showGalleryIcon = true,
    this.showFlashIcon = true,
    this.showCameraSwitchIcon = true,
  });

  final PreferredSizeWidget? customAppBar;
  final Widget? customBottomBar;
  final Icon? closeIcon;
  final Icon? galleryIcon;
  final Icon? flashIcon;
  final Icon? cameraSwitchIcon;
  final bool showCloseIcon;
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
            leading: widget.showCloseIcon
                ? IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: RotatedIcon(
                      widget.closeIcon ?? const Icon(Icons.close),
                    ),
                  )
                : null,
            actions: [
              if (widget.showFlashIcon)
                IconButton(
                  onPressed: () {},
                  icon: RotatedIcon(
                    widget.flashIcon ??
                        const Icon(
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
                      icon: RotatedIcon(
                        widget.galleryIcon ?? const Icon(Icons.folder_copy),
                      ),
                    ),
                  if (widget.showCameraSwitchIcon)
                    IconButton(
                      // TODO: Add functionality
                      onPressed: () {},
                      // TODO: Change icon
                      icon: RotatedIcon(
                        widget.cameraSwitchIcon ?? const Icon(Icons.cameraswitch),
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
