import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sighttrack_app/components/button.dart';
import 'package:sighttrack_app/components/text_field_modern.dart';
import 'package:sighttrack_app/design.dart';
import 'package:sighttrack_app/util/error_message.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  TextEditingController confirmDeletionController = TextEditingController();

  Future<void> onDeleteAccount() async {
    if (confirmDeletionController.text == "confirm") {
      try {
        await Amplify.Auth.deleteUser();
      } on AuthException catch (e) {
        if (!mounted) return;
        showErrorMessage(context, "$e");
      }
    } else {
      showErrorMessage(context, "You must type 'confirm' to continue");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Account"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: Looks.pagePadding,
                child: Column(
                  children: [
                    Text(
                      "By deleting your account, you delete all references to you. Meaning your uploads, comments, or any other app interactions will still exist; however, they will then belong to Deleted Account, not you.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "For example, if a user TestUser commented on a post, they're seen as Deleted User once they deleted their account and their past interactions are observed by other users.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 30),
                    CustomModernTextField(
                        controller: confirmDeletionController,
                        labelText: "Confirm account deletion",
                        hintText: "Type 'confirm' to delete your account"),
                    const SizedBox(height: 30),
                    CustomButton(
                        onTap: onDeleteAccount, label: "Delete Account"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
