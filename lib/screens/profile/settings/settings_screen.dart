// import 'dart:async';
// import 'dart:collection';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'dart:convert';
import 'package:pit_care/components/ui/navigation/custom_app_bar.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        backgroundBar: Colors.transparent,
        title: 'Настройки',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [],
        centerTitle: true,
        showPoints: false,
      ),
      body: const Column(
        children: [
          SizedBox(height: 24),
          //
          // Center(child: Text('Settings Screen')),
        ],
      ),
    );
  }
}
