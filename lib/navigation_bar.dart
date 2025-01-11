import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:google_nav_bar/google_nav_bar.dart";
import "package:sighttrack_app/screens/capture/capture.dart";
import "package:sighttrack_app/screens/data/data.dart";
import "package:sighttrack_app/screens/map/map.dart";
import "package:sighttrack_app/screens/profile/profile.dart";

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex = 1;
  bool doneInitializing = false;
  late List<Widget> widgetOptions;
  late CameraDescription? camera;

  Future<void> initializeElements() async {
    final cameras = await availableCameras();

    setState(() {
      try {
        camera = cameras.first;
      } catch (e) {
        camera = null;
      }
      widgetOptions = <Widget>[
        const MapScreen(),
        CaptureScreenHandler(camera: camera),
        const DataScreen(),
        const ProfileScreen(),
      ];
      doneInitializing = true;
    });
  }

  @override
  void initState() {
    super.initState();

    doneInitializing = false;

    initializeElements();
  }

  @override
  Widget build(BuildContext context) {
    return !doneInitializing
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: widgetOptions.elementAt(selectedIndex),
            bottomNavigationBar: Container(
              color: Colors.teal,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: GNav(
                  gap: 8,
                  backgroundColor: Colors.teal,
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors.grey.shade800,
                  padding: const EdgeInsets.all(16),
                  selectedIndex: selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  tabs: const [
                    GButton(icon: Icons.home, text: "Home"),
                    GButton(icon: Icons.camera_alt, text: "Capture"),
                    GButton(icon: Icons.trending_up_sharp, text: "Data"),
                    GButton(icon: Icons.person, text: "Profile"),
                  ],
                ),
              ),
            ),
          );
  }
}
