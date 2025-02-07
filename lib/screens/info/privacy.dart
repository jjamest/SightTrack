import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onNavigationRequest: (request) {
            if (request.url.startsWith("https://www.sighttrack.org")) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
        Uri.parse("https://www.sighttrack.org/privacy-policy.html"),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Policy")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ), // Show loader while loading
        ],
      ),
    );
  }
}
