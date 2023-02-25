import 'package:flutter/material.dart';

class SnapNSelect extends StatefulWidget {
  const SnapNSelect({
    super.key,
    this.customAppBar,
    this.customBottomBar,
  });

  final PreferredSizeWidget? customAppBar;
  final Widget? customBottomBar;

  @override
  State<SnapNSelect> createState() => _SnapNSelectState();
}

class _SnapNSelectState extends State<SnapNSelect> {
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
              icon: const Icon(Icons.close),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.flash_off),
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
                  IconButton(
                    // TODO: Add functionality
                    onPressed: () {},
                    // TODO: Change icon
                    icon: Icon(Icons.folder_copy),
                  ),
                  IconButton(
                    // TODO: Add functionality
                    onPressed: () {},
                    // TODO: Change icon
                    icon: Icon(Icons.cameraswitch),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
