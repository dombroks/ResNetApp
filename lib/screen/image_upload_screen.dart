import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img; // Import the image package

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({Key? key}) : super(key: key);

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  String _apiResponse = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage(String base64Image) async {
    debugPrint("at the method");
    const apiUrl =
        'http://192.168.1.68:8000/api/predict/'; // Replace with your API URL

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'image': base64Image}),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("200");
        final responseData = jsonDecode(response.body);
        final prediction = responseData['prediction'];
        final score = responseData['score'];
        setState(() {
          _apiResponse = 'Prediction: $prediction\nScore: $score';
        });
      } else {
        debugPrint("failed");
        setState(() {
          _apiResponse = 'Error: Could not process the image';
        });
      }
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
      });
    }
  }

  Future<void> _selectImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      final List<int> imageBytes = await imageFile.readAsBytes();

      final img.Image? decodedImage =
          img.decodeImage(Uint8List.fromList(imageBytes));

      if (decodedImage != null) {
        final String base64Image =
            base64Encode(img.encodeJpg(decodedImage)); // Convert to base64
        _uploadImage(base64Image);
      } else {
        setState(() {
          _apiResponse = 'Error: Could not decode the selected image';
        });
      }
    } else {
      setState(() {
        _apiResponse = 'No image selected';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _selectImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 16),
            Text(
              _apiResponse,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
