import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:snap_n_select/src/rotated_icon.dart';
import 'package:snap_n_select/src/tab_chip.dart';
import 'package:snap_n_select/src/util.dart';

enum Tab { video, photo }

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
    this.showZoomOverlay = true,
    this.bottomBarPadding,
    this.showBottomBar = true,
    this.defaultTab = Tab.photo,
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
  final bool showZoomOverlay;
  final EdgeInsetsGeometry? bottomBarPadding;
  final bool showBottomBar;
  final Tab? defaultTab;

  @override
  State<SnapNSelect> createState() => _SnapNSelectState();
}

class _SnapNSelectState extends State<SnapNSelect> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentZoomLevel = 1.0;
  bool showZoomOverlay = false;
  bool isTakingPicture = false;
  bool isRecording = false;
  List<XFile> mediaList = [];
  Tab currentTab = Tab.photo;
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;
  AppLifecycleState? _appLifecycleState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
    });

    print(state.toString());

    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    if (_ticker != null) {
      _ticker!.dispose();
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.removeObserver(this);
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

      cameraController!.getMaxZoomLevel().then((value) => maxAvailableZoom = value);
      cameraController!.getMinZoomLevel().then((value) => minAvailableZoom = value);
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

  Future<void> takePicture() async {
    setState(() {
      isTakingPicture = true;
    });

    try {
      final XFile file = await cameraController!.takePicture();
      mediaList.add(file);
      setState(() {
        isTakingPicture = false;
      });
    } on CameraException catch (exception) {
      // TODO: Replace or remove exception entirely
      print(exception);
      return;
    }
  }

  Future<void> startRecording() async {
    try {
      await cameraController!.startVideoRecording();

      final DateTime initialTimer = DateTime.now();
      _ticker = createTicker((elapsed) {
        final now = DateTime.now();

        setState(() {
          _elapsed = now.difference(initialTimer);
        });
      });
      _ticker!.start();

      setState(() {
        isRecording = true;
      });
    } on CameraException catch (exception) {
      // TODO: Replace or remove exception entirely
      print(exception);
      return;
    }
  }

  Future<void> stopRecording() async {
    try {
      final XFile file = await cameraController!.stopVideoRecording();
      mediaList.add(file);
      _ticker!.stop();

      setState(() {
        isRecording = false;
        _elapsed = Duration.zero;
      });
    } on CameraException catch (exception) {
      // TODO: Replace or remove exception entirely
      print(exception);
      return;
    }
  }

  Widget getCameraButton() {
    if (currentTab.name == 'photo') {
      return AnimatedContainer(
        width: isTakingPicture ? 90 : 60,
        height: isTakingPicture ? 90 : 60,
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3.0,
          ),
        ),
        child: Container(
          width: isTakingPicture ? 70 : 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      return AnimatedContainer(
        width: isRecording ? 90 : 60,
        height: isRecording ? 90 : 60,
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3.0,
          ),
        ),
        child: Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: isRecording ? Colors.red : Colors.white,
            shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isRecording ? BorderRadius.circular(6) : null,
          ),
        ),
      );
    }
  }

  static String getDuration(Duration duration) {
    final List<String> tokens = [];

    int seconds = duration.inSeconds;
    final int days = seconds ~/ Duration.secondsPerDay;

    seconds -= days * Duration.secondsPerDay;
    final int hours = seconds ~/ Duration.secondsPerHour;

    seconds -= hours * Duration.secondsPerHour;
    final int minutes = seconds ~/ Duration.secondsPerMinute;

    seconds -= minutes * Duration.secondsPerMinute;

    if (days != 0) {
      tokens.add('$days');
    }

    if (tokens.isNotEmpty || hours != 0) {
      if (hours < 10) {
        tokens.add('0$hours');
      } else {
        tokens.add('$hours');
      }
    }

    if (minutes < 10) {
      tokens.add('0$minutes');
    } else {
      tokens.add('$minutes');
    }

    if (seconds < 10) {
      tokens.add('0$seconds');
    } else {
      tokens.add('$seconds');
    }

    return tokens.join(':');
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
            centerTitle: true,
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
            title: (isRecording || currentTab.name == 'video')
                ? CustomChip(
                    label: Text(getDuration(_elapsed)),
                    style: TextStyle(color: Colors.white),
                    backgroundColor: isRecording ? Colors.red : Colors.black.withOpacity(0.3),
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
      body: GestureDetector(
        onScaleStart: (ScaleStartDetails details) {
          if (widget.showZoomOverlay && details.pointerCount >= 2) {
            setState(() {
              showZoomOverlay = true;
            });
          }
        },
        onScaleUpdate: (ScaleUpdateDetails details) async {
          final double scale = details.scale;

          if (details.pointerCount >= 2) {
            if (scale < 1) {
              currentZoomLevel = 1.0;
            } else if (scale > 1 && scale < maxAvailableZoom) {
              currentZoomLevel = minAvailableZoom * scale;
            } else {
              currentZoomLevel = maxAvailableZoom;
            }

            if (mounted) {
              if (widget.showZoomOverlay) {
                showZoomOverlay = true;
              }

              setState(() {});
            }
            await cameraController!.setZoomLevel(currentZoomLevel);
          }
        },
        onScaleEnd: (ScaleEndDetails details) async {
          if (widget.showZoomOverlay && details.pointerCount >= 2) {
            await Future.delayed(const Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  showZoomOverlay = false;
                });
              }
            });
          }
        },
        child: Stack(
          children: [
            Builder(
              builder: (BuildContext context) {
                if (isInitialized) {
                  return cameraWidget(context);
                }

                return const SizedBox.shrink();
              },
            ),
            Visibility(
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              visible: showZoomOverlay,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                    ),
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      const double minWidth = 60;

                      return Container(
                        width: minWidth * currentZoomLevel,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                          ),
                        ),
                        child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // TODO: Add optional color to show more the text
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                            ),
                          ),
                          child: Text(
                            'x${currentZoomLevel.toPrecision()}',
                            // TODO: Add optional TextStyle parameter
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (widget.cameraOverlay != null)
              Center(
                child: widget.cameraOverlay,
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Builder(
                builder: (BuildContext context) {
                  if (widget.customBottomBar != null) {
                    return widget.customBottomBar!;
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 130,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
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
                                GestureDetector(
                                  onTap: () {
                                    if (currentTab.name == 'video') {
                                      if (!isRecording) {
                                        startRecording();
                                      } else {
                                        stopRecording();
                                      }
                                    } else if (currentTab.name == 'photo') {
                                      takePicture();
                                    }
                                  },
                                  onLongPress: () {
                                    if (!isRecording) {
                                      startRecording();
                                    }
                                  },
                                  onLongPressUp: () {
                                    if (isRecording) {
                                      stopRecording();
                                    }
                                  },
                                  child: getCameraButton(),
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
                          ],
                        ),
                      ),
                      if (widget.customBottomBar != null)
                        widget.customBottomBar!
                      else if (widget.showBottomBar)
                        Container(
                          height: 100,
                          width: double.maxFinite,
                          padding: const EdgeInsets.only(top: 15),
                          color: Colors.grey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TabChip(
                                    label: Text('video'),
                                    selected: currentTab.name == 'video',
                                    onSelected: (_) {
                                      if (currentTab.name == 'photo') {
                                        setState(() {
                                          currentTab = Tab.video;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 15),
                                  TabChip(
                                    label: Text('photo'),
                                    selected: currentTab.name == 'photo',
                                    onSelected: (_) {
                                      if (currentTab.name == 'video') {
                                        setState(() {
                                          currentTab = Tab.photo;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
