import 'package:flutter/material.dart';

class SnapNSelect extends StatelessWidget {
  const SnapNSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
      body: SingleChildScrollView(),
    );
  }
}
