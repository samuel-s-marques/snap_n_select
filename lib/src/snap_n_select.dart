import 'package:flutter/material.dart';

class SnapNSelect extends StatelessWidget {
  const SnapNSelect({
    super.key,
    this.customAppBar,
    this.customBottomBar,
  });

  final PreferredSizeWidget? customAppBar;
  final Widget? customBottomBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBar ??
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

          if (customBottomBar != null)
            customBottomBar!
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
