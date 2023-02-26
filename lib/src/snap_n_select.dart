import 'package:camera/camera.dart';
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
    this.showSystemTopOverlay = false,
    this.showSystemBottomOverlay = true,
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
  final bool showSystemTopOverlay;
  final bool showSystemBottomOverlay;

  @override
  State<SnapNSelect> createState() => _SnapNSelectState();
}

class _SnapNSelectState extends State<SnapNSelect> {
  CameraController? cameraController;
  bool isInitialized = false;
  List<SystemUiOverlay> systemUiOverlays = [];

  @override
  void initState() {
    super.initState();

    initialize();

    if (widget.showSystemTopOverlay) {
      systemUiOverlays.add(SystemUiOverlay.top);
    }

    if (widget.showSystemBottomOverlay) {
      systemUiOverlays.add(SystemUiOverlay.bottom);
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: systemUiOverlays);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();

    cameraController!.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> initialize() async {
    final List<CameraDescription> cameras = await availableCameras();

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.max,
    );

    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isInitialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
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
                      widget.closeIcon ?? const Icon(Icons.close, color: Colors.white),
                    ),
                  )
                : null,
            actions: [
              if (widget.showFlashIcon)
                IconButton(
                  onPressed: () {},
                  icon: RotatedIcon(
                    widget.flashIcon ?? const Icon(Icons.flash_off, color: Colors.white),
                  ),
                ),
            ],
          ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (isInitialized) {
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: CameraPreview(cameraController!),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (BuildContext context) {
          if (widget.customBottomBar != null) {
            return widget.customBottomBar!;
          }

          return Padding(
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
                      widget.galleryIcon ?? const Icon(Icons.folder_copy, color: Colors.white),
                    ),
                  ),
                if (widget.showCameraSwitchIcon)
                  IconButton(
                    // TODO: Add functionality
                    onPressed: () {},
                    // TODO: Change icon
                    icon: RotatedIcon(
                      widget.cameraSwitchIcon ?? const Icon(Icons.cameraswitch, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
