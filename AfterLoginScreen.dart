import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fyp_lungs_disease/scan.dart';
import 'package:image_picker/image_picker.dart';

class AfterLoginScreen extends StatefulWidget {
  const AfterLoginScreen({super.key});

  @override
  _AfterLoginScreenState createState() => _AfterLoginScreenState();
}

class _AfterLoginScreenState extends State<AfterLoginScreen> {
  final String _serverResponse = '';

  final List<String> categories = [
    "Normal",
    "TB",
    "Covid-19",
    "Viral Pneumonia",
    "Bacterial Pneumonia",
  ];

  int _currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _startCategoryAnimation();
  }

  void _startCategoryAnimation() {
    Future.delayed(Duration.zero, () {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        setState(() {
          _currentCategoryIndex =
              (_currentCategoryIndex + 1) % categories.length;
        });
      });
    });
  }

  Future<void> _takePicture(BuildContext context) async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 400, maxWidth: 400);
    if (image != null) {
      File imageFile = File(image.path);
      await _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      await _uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var data = FormData.fromMap({
      'file': [
        await MultipartFile.fromFile(imageFile.path, filename: imageFile.path)
      ],
    });

    var dio = Dio();
    var response = await dio.request(
      'https://imagerandom-9bbb4770f803.herokuapp.com/predict',
      options: Options(
        method: 'POST',
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      dynamic data = json.encode(response.data);
      print('Image sent successfully');
      var responseBody = data;
      _showResultDialog(context, responseBody);
    } else {
      print(response.statusMessage);
    }
  }

  void _showResultDialog(BuildContext context, String response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return response.isNotEmpty
            ? AlertDialog(
          title: const Text("Result"),
          content: SingleChildScrollView(
            child: Text(response),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        )
            : AlertDialog(
          title: const Text("Error"),
          content: const Text("No results available."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Dynamically calculate the box size based on screen width
    double boxSize = screenWidth > 400 ? 60 : 40;

    return Scaffold(
      appBar: AppBar(
        title: const Text("WELCOME"),
        backgroundColor:  Color.fromRGBO(236, 87, 137, 1),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
          color: Colors.white,
        ),iconTheme: IconThemeData(
        color: Colors.white,
      ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Background color
              // image: DecorationImage(
              //   image: AssetImage('assets/images/image_lungs_4.png'),
              //   fit: BoxFit.fitHeight,
              // ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 50), // Space below AppBar
              const Center(
                child: Text(
                  "Automatic Lungs Disease Detection",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40), // Space below title
              Expanded(
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20, // Horizontal spacing
                      runSpacing: 20, // Vertical spacing
                      children: categories
                          .map((category) =>
                          _buildCategoryShape(category, boxSize))
                          .toList(),
                    ),
                    const SizedBox(height: 70), // Space below categories
                    const Center(
                      child: Text(
                        "Detect Your Disease With AI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60), // Space below description
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImageRecognitionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15), // Button padding
                  backgroundColor: Color.fromRGBO(255, 158, 202, 1),

    ),
                child: const Text(
                  "Scan Now",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20), // Space between buttons
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15), // Button padding
                  backgroundColor: Color.fromRGBO(255, 158, 202, 1),

    ),
                child: const Text(
                  "View History",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const Spacer(), // Push the footer to the bottom
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "Project by \nIqra Mahmood(030) \nHamza Rajab(026) \nAnjleena Khurram(012)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        "Supervised By \nASAD JAVED",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryShape(String categoryName, double boxSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:Color.fromRGBO(236, 87, 137, 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        categoryName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: boxSize / 5, // Dynamically adjust text size
          color: Colors.white,
        ),
      ),
    );
  }
}
