import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sighttrack/models/User.dart';
import 'package:sighttrack/widgets/button.dart';

class ChangeProfilePictureScreen extends StatefulWidget {
  final User user;
  const ChangeProfilePictureScreen({super.key, required this.user});

  @override
  State<ChangeProfilePictureScreen> createState() =>
      _ChangeProfilePictureScreenState();
}

class _ChangeProfilePictureScreenState
    extends State<ChangeProfilePictureScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Opens the gallery for image selection.
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage == null) return;

    try {
      // Generate a unique storage path.
      final String storagePath =
          "profile_pictures/${widget.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Create an AWSFile from the local image file.
      final awsFile = AWSFile.fromPath(_selectedImage!.path);

      // 1. Upload the file using the new API parameters.
      final uploadResult = await Amplify.Storage.uploadFile(
        localFile: awsFile,
        path: StoragePath.fromString(storagePath),
      ).result;
      safePrint('Uploaded file: ${uploadResult.uploadedItem.path}');

      // 2. Retrieve the URL of the uploaded file using options similar to the documentation.
      final getUrlResult = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(storagePath),
        options: StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(days: 1),
          ),
        ),
      ).result;
      final String imageUrl = getUrlResult.url.toString();

      // 3. Update the user's profile picture in DataStore.
      final updatedUser = widget.user.copyWith(profilePicture: imageUrl);
      await Amplify.DataStore.save(updatedUser);

      // 4. Provide success feedback and navigate back.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!")),
      );
      Navigator.of(context).pop();
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("StorageException: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile picture: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Profile Picture"),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the selected image, user's current image, or a default icon.
            CircleAvatar(
              radius: 150,
              backgroundColor: Colors.grey,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : widget.user.profilePicture != null
                      ? NetworkImage(widget.user.profilePicture!)
                          as ImageProvider<Object>?
                      : null,
              child:
                  _selectedImage == null && widget.user.profilePicture == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Select Image"),
            ),
            const SizedBox(height: 24),
            // The save button is disabled until an image is selected.
            Center(
              child: SightTrackButton(
                text: "Save",
                onPressed: _selectedImage == null ? null : _saveImage,
                loading: false,
                width: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
