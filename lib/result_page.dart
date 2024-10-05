import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatelessWidget {
  final String safetyStatus; // Safety status message
  final List<dynamic> output; // List of product information

  const ResultPage({
    Key? key,
    required this.safetyStatus,
    required this.output,
  }) : super(key: key);

  // Function to launch URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Status: $safetyStatus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (output.isEmpty) 
              Text('No products found.')
            else 
              Expanded(
                child: ListView.builder(
                  itemCount: output.length,
                  itemBuilder: (context, index) {
                    final product = output[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product: ${product['product_name']}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text('Ingredients: ${product['ingredients_text']}'),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                _launchURL(product['url']); // Make URL clickable
                              },
                              child: Text(
                                'URL: ${product['url']}',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
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