import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';  // Add this import
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class DownSyndromeDetectionPage extends StatefulWidget {
  @override
  _DownSyndromeDetectionPageState createState() => _DownSyndromeDetectionPageState();
}

class _DownSyndromeDetectionPageState extends State<DownSyndromeDetectionPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _result = "";
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = pickedFile != null ? File(pickedFile.path) : null;
        _result = "";
      });
      print("Image picked: ${_image?.path}");
    } catch (e) {
      print("Error picking image: $e");
      setState(() {
        _result = "Error picking image: $e";
      });
    }
  }

  Future<void> _detectDownSyndrome() async {
    if (_image == null) {
      setState(() {
        _result = "Please select an image first.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = "Processing...";
    });

    try {
      print("File size: ${await _image!.length()} bytes");

      final url = Uri.parse('http://192.168.4.28:8000/predict');
      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      // Updated MultipartFile creation with MediaType from http_parser
      var multipartFile = await http.MultipartFile.fromPath(
          'file',
          _image!.path,
          contentType: MediaType('image', 'jpeg')  // Now using the correct MediaType
      );
      request.files.add(multipartFile);

      print("Sending request to: $url");
      var streamedResponse = await request.send();
      print("Response status code: ${streamedResponse.statusCode}");

      var response = await http.Response.fromStream(streamedResponse);
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        setState(() {
          _result = "Prediction: ${result['prediction']}\nConfidence: ${result['confidence']}";
        });
      } else {
        setState(() {
          _result = "Server error (${response.statusCode}): ${response.body}";
        });
      }
    } catch (e) {
      print("Error during upload: $e");
      setState(() {
        _result = "Network error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Down Syndrome Detection"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text("No image selected", style: TextStyle(color: Colors.black54)),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_image!, height: 200),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImage,
              child: Text("Choose Image"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _detectDownSyndrome,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            if (_result.isNotEmpty)
              Card(
                elevation: 3,
                color: Colors.blue[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _result,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}