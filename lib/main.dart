import 'package:flutter/material.dart';
import 'package:wallpaper_app/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      builder: (context, child) {
        return SafeArea(child: child!);
      },
      home: Home(),
    );
  }
}
