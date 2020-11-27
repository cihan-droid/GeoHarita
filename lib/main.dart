import 'package:flutter/material.dart';
import 'harita/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Harita",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Harita(),
    );
  }
}
