import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ReviewUploadScreen extends StatefulWidget {
  const ReviewUploadScreen(
      {super.key, required this.labels, required this.image});

  final List<dynamic> labels;
  final XFile image;

  @override
  State<ReviewUploadScreen> createState() => _ReviewUploadScreenState();
}

class _ReviewUploadScreenState extends State<ReviewUploadScreen> {
  String? selectedLabel;

  @override
  void initState() {
    super.initState();

    // Set default label to the one with the highest confidence
    if (widget.labels.isNotEmpty) {
      widget.labels.sort((a, b) =>
          (b['Confidence'] as double).compareTo(a['Confidence'] as double));
      selectedLabel = widget.labels.first['Name'];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Preview your upload"),
      ),
      body: SingleChildScrollView(
        // Wrap the body in a scroll view for better usability
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Styled explanatory text
                    Text(
                      'Select the animal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Modern dropdown for selecting the label with the highest confidence
                    if (widget.labels.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.shade200,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButton<String>(
                          value: selectedLabel,
                          isExpanded: true,
                          underline:
                              const SizedBox(), // Remove the default underline
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          items: widget.labels.map((label) {
                            return DropdownMenuItem<String>(
                              value: label['Name'],
                              child: Text(
                                label['Name'],
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedLabel = newValue;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Displaying the image
              Image.file(
                File(widget.image.path),
                width: screenWidth,
                height: null,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
