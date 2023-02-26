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
    this.cameraOverlay,
    this.resolutionPreset = ResolutionPreset.max,
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
  final Widget? cameraOverlay;
  final ResolutionPreset resolutionPreset;

  @override
  State<SnapNSelect> createState() => _SnapNSelectState();
}

class _SnapNSelectState extends State<SnapNSelect> {
  CameraController? cameraController;
  bool isInitialized = false;
  bool isRearCameraSelected = false;
  FlashMode? flashMode;
  Map<FlashMode, IconData> flashModes = {
    FlashMode.off: Icons.flash_off,
    FlashMode.auto: Icons.flash_auto,
    FlashMode.always: Icons.flash_on,
    FlashMode.torch: Icons.flashlight_on,
  };

  @override
  void initState() {
    super.initState();

    initialize();

    final List<SystemUiOverlay> systemUiOverlays = [];
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> initialize({int cameraIndex = 0}) async {
    final List<CameraDescription> cameras = await availableCameras();

    cameraController = CameraController(
      cameras[cameraIndex],
      widget.resolutionPreset,
    );

    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isInitialized = true;
        flashMode = cameraController!.value.flashMode;
      });
    });
  }

  void switchCamera() {
    setState(() {
      isInitialized = false;
    });

    initialize(cameraIndex: isRearCameraSelected ? 0 : 1);

    setState(() {
      isRearCameraSelected = !isRearCameraSelected;
    });
  }

  Widget cameraWidget(BuildContext context) {
    final CameraValue cameraValue = cameraController!.value;
    final Size size = MediaQuery.of(context).size;
    double scale = size.aspectRatio * cameraValue.aspectRatio;

    if (scale < 1) {
      scale = 1 / scale;
    }

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(cameraController!),
      ),
    );
  }

  void changeFlashMode() {
    switch (flashMode) {
      case FlashMode.off:
        flashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        flashMode = FlashMode.always;
        break;
      case FlashMode.always:
        flashMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        flashMode = FlashMode.off;
        break;
      default:
        flashMode = FlashMode.off;
        break;
    }

    setState(() {});
    cameraController!.setFlashMode(flashMode!);
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
                  onPressed: () {
                    changeFlashMode();
                  },
                  icon: RotatedIcon(
                    widget.flashIcon ?? Icon(flashModes[flashMode], color: Colors.white),
                  ),
                ),
            ],
          ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (isInitialized) {
                return cameraWidget(context);
              }

              return const SizedBox.shrink();
            },
          ),
          if (widget.cameraOverlay != null)
            Center(
              child: widget.cameraOverlay,
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
                    icon: RotatedIcon(
                      widget.galleryIcon ?? const Icon(Icons.folder_copy, color: Colors.white),
                    ),
                  ),
                if (widget.showCameraSwitchIcon)
                  IconButton(
                    onPressed: () => switchCamera(),
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
