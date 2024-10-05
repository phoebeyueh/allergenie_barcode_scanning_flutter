import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'upload_image_page.dart'; 
import 'result_page.dart'; 


class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<String> uploadImage(Uint8List imageData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/upload'), 
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'image': base64Encode(imageData)}),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to upload image');
    }
  }
}