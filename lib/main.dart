import 'package:flutter/material.dart';
import 'upload_image_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Allergy Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UploadImagePage(),
    );
  }
}