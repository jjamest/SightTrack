import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/aws/dynamo.dart';
import 'package:sighttrack_app/components/button.dart';
import 'package:sighttrack_app/components/success.dart';
import 'package:sighttrack_app/components/text_box.dart';
import 'package:sighttrack_app/models/photo_marker.dart';
import 'package:sighttrack_app/navigation_bar.dart';

class ReviewCaptureScreen extends StatefulWidget {
  const ReviewCaptureScreen(
      {super.key,
      required this.labels,
      required this.image,
      required this.photoMarker});

  final List<dynamic> labels;
  final XFile image;
  final PhotoMarker photoMarker;

  @override
  State<ReviewCaptureScreen> createState() => _ReviewCaptureScreenState();
}

class _ReviewCaptureScreenState extends State<ReviewCaptureScreen> {
  late String selectedLabel;
  bool isLoading = false;
  final TextEditingController descriptionController = TextEditingController();

  void onUpload() async {
    setState(() {
      isLoading = true;
    });

    // Update photoMarker instance
    widget.photoMarker.label = selectedLabel;
    widget.photoMarker.description = descriptionController.text;

    await savePhotoMarker(widget.photoMarker);

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
            text: 'Upload Complete!',
            subText: 'Your file has been successfully uploaded.',
            destination: const CustomNavigationBar()),
      ),
    );
  }

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
        title: const Text('Review your upload'),
      ),
      body: SingleChildScrollView(
        // Wrap the body in a scroll view for better usability
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                        'Describe your photo',
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
                                selectedLabel = newValue!;
                              });
                            },
                          ),
                        ),
                      const SizedBox(height: 30),
                      CustomTextBox(
                          label: 'Description',
                          hintText: 'Enter your description here...',
                          controller: descriptionController),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                isLoading
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(), // Loading spinner
                          SizedBox(height: 20),
                          Text(
                            "Uploading...",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      )
                    : CustomButton(onTap: onUpload, label: 'Upload Image'),

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
      ),
    );
  }
}
