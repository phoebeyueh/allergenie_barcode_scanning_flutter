import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'result_page.dart'; 

class UploadImagePage extends StatefulWidget {
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  Uint8List? imageData;
  final ApiService apiService = ApiService('http://127.0.0.1:5000'); // Set your base API URL

  // List of allergens
  List<String> allergens = [
    'milk',
    'gluten',
    'nuts',
    'soybeans',
    'peanuts',
    'celery',
    'crustaceans',
    'mustard',
    'sesame-seeds'
  ];
  List<String> selectedAllergens = []; // Selected allergens

  // Step 1: Allergen Selection
  Widget allergenSelection() {
    return Wrap(
      spacing: 10, 
      runSpacing: 10,
      children: allergens.map((allergen) {
        return FilterChip(
          label: Text(allergen, style: TextStyle(fontSize: 16)),
          selected: selectedAllergens.contains(allergen),
          onSelected: (bool value) {
            toggleAllergen(allergen);
          },
          selectedColor: Colors.white, 
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: selectedAllergens.contains(allergen) ? Colors.black : Colors.black, // Change label text color to black
          ),
        );
      }).toList(),
    );
  }

  // Step 2: Image Upload
  void pickImage() {
    if (kIsWeb) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);

        reader.onLoadEnd.listen((e) {
          setState(() {
            imageData = reader.result as Uint8List?;
          });
        });
      });
    } else {
      final picker = ImagePicker();
      picker.pickImage(source: ImageSource.gallery).then((pickedFile) {
        setState(() {
          if (pickedFile != null) {
            pickedFile.readAsBytes().then((bytes) {
              imageData = bytes;
            });
          }
        });
      });
    }
  }

  void uploadImage(Uint8List imageData) async {
    try {
      final response = await http.post(
        Uri.parse('${apiService.baseUrl}/upload'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'image': base64Encode(imageData),
          'allergens': selectedAllergens, // Include selected allergens
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              safetyStatus: responseData['safety_status'],
              output: responseData['output'],
            ),
          ),
        );
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Toggle selected allergens
  void toggleAllergen(String allergen) {
    setState(() {
      if (selectedAllergens.contains(allergen)) {
        selectedAllergens.remove(allergen);
      } else {
        selectedAllergens.add(allergen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 95, 8, 110),
        title: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Text(
                    'Welcome to AllerGenie!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'This is your place for real-time allergen detection.',
                    style: TextStyle(color: Colors.white70, fontSize: 14), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100, 
                ),
              ),
            ),
            Text(
              'Step 1: Select Allergens',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),

            // Instruction text for uploading barcode image
            Text(
              'Please upload a barcode image from your device.',
              style: TextStyle(fontSize: 16, color: Colors.black54), 
              textAlign: TextAlign.center, 
            ),
            SizedBox(height: 20),
            allergenSelection(),
            SizedBox(height: 40),

            // Step 2: Upload Barcode Image
            Text(
              'Step 2: Upload Barcode Image',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),

            // Instruction text for uploading barcode image
            Text(
              'Please upload a barcode image from your device.',
              style: TextStyle(fontSize: 16, color: Colors.black54), // Adjust style as needed
              textAlign: TextAlign.center, // Center the text
            ),
            SizedBox(height: 10),
            imageData != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.memory(
                      imageData!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Icon(Icons.image, size: 100, color: Colors.grey),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.upload, size: 24),
              label: Text('Select Barcode Image', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 40),

            // Submit button to check for allergens
            ElevatedButton.icon(
              onPressed: imageData != null
                  ? () => uploadImage(imageData!)
                  : null, // Check allergens only if image is uploaded
              icon: Icon(Icons.check_circle, size: 24),
              label: Text('Check for Allergens', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}