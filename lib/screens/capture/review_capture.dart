import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/services/photomarker_service.dart";
import "package:sighttrack_app/components/buttons.dart";
import "package:sighttrack_app/components/text.dart";
import "package:sighttrack_app/util/error_message.dart";
import "package:sighttrack_app/widgets/success.dart";
import "package:sighttrack_app/models/photomarker.dart";
import "package:sighttrack_app/navigation_bar.dart";

class ReviewCaptureScreen extends StatefulWidget {
  const ReviewCaptureScreen({
    super.key,
    required this.labels,
    required this.image,
    required this.photoMarker,
  });

  final List<dynamic> labels;
  final XFile image;
  final PhotoMarker photoMarker;

  @override
  State<ReviewCaptureScreen> createState() => _ReviewCaptureScreenState();
}

class _ReviewCaptureScreenState extends State<ReviewCaptureScreen> {
  bool isLoading = false;
  bool addCustomLabel = false;
  late String selectedLabel;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController customLabelController = TextEditingController();

  void onUpload() async {
    if (addCustomLabel) {
      if (customLabelController.text == "") {
        showErrorMessage(context, "You must add a valid label");
        return;
      } else {
        widget.photoMarker.label = customLabelController.text;
      }
    } else {
      widget.photoMarker.label = selectedLabel;
    }
    widget.photoMarker.description = descriptionController.text;

    setState(() {
      isLoading = true;
    });

    await savePhotoMarker(widget.photoMarker);

    setState(() {
      isLoading = false;
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          text: "Upload Complete!",
          subText: "Your file has been successfully uploaded.",
          destination: const CustomNavigationBar(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Set default label to the one with the highest confidence
    if (widget.labels.isNotEmpty) {
      widget.labels.sort(
        (a, b) =>
            (b["Confidence"] as double).compareTo(a["Confidence"] as double),
      );
      selectedLabel = widget.labels.first["Name"];
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
        title: const Text("Review your upload"),
      ),
      body: SingleChildScrollView(
        // Wrap the body in a scroll view for better usability
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Padding(
            padding: Looks.pagePadding,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  LargeTextField(
                    controller: descriptionController,
                    labelText: "Description",
                    hintText: "Describe your photo here",
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      addCustomLabel ? "Add custom label" : "Detected Labels",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dropdown for selecting the label with the highest confidence
                  if (widget.labels.isNotEmpty && !addCustomLabel)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: selectedLabel,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        items: widget.labels.map((label) {
                          return DropdownMenuItem<String>(
                            value: label["Name"],
                            child: Text(
                              label["Name"],
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

                  const SizedBox(height: 10),
                  if (!addCustomLabel)
                    TextLinkAndIcon(
                      text: "Don't see an option?",
                      onPressed: () {
                        setState(() {
                          addCustomLabel = true;
                        });
                      },
                      icon: false,
                    ),
                  if (addCustomLabel)
                    Column(
                      children: [
                        LargeTextField(
                          controller: customLabelController,
                          labelText: "",
                          hintText: "Add your label here",
                        ),
                        const SizedBox(height: 10),
                        TextLinkAndIcon(
                          text: "Go back to detected labels?",
                          onPressed: () {
                            setState(() {
                              addCustomLabel = false;
                            });
                          },
                          icon: false,
                        ),
                      ],
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        )
                      : LargeButton(onTap: onUpload, label: "Upload Image"),

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
      ),
    );
  }
}
