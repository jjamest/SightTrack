import "package:camera/camera.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:google_nav_bar/google_nav_bar.dart";
import "package:provider/provider.dart";
import "package:sighttrack_app/models/user_state.dart";
import "package:sighttrack_app/screens/admin/admin.dart";
import "package:sighttrack_app/screens/capture/capture.dart";
import "package:sighttrack_app/screens/data/data.dart";
import "package:sighttrack_app/screens/map/map.dart";
import "package:sighttrack_app/screens/moderator/moderator.dart";
import "package:sighttrack_app/screens/profile/profile.dart";
import "package:sighttrack_app/services/user_service.dart";

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex = 1;
  bool doneInitializing = false;
  late List<Widget> widgetOptions;
  late List<GButton> navTabs;
  late CameraDescription? camera;
  late UserState userState;

  Future<void> initializeElements() async {
    final cameras = await availableCameras();

    // Initialize camera
    CameraDescription? tempCamera;
    try {
      tempCamera = cameras.isNotEmpty ? cameras.first : null;
    } catch (e) {
      tempCamera = null;
    }

    List<Widget> tempWidgets = [
      const MapScreen(),
      CaptureScreenHandler(camera: tempCamera),
      const DataScreen(),
      const ProfileScreen(),
    ];

    List<GButton> tempTabs = [
      GButton(icon: Icons.home, text: "Home"),
      GButton(icon: Icons.camera_alt, text: "Capture"),
      GButton(icon: Icons.trending_up_sharp, text: "Data"),
      GButton(icon: Icons.person, text: "Profile"),
    ];

    if (userState.roles.contains("Admin")) {
      tempWidgets.add(const AdminScreen());
      tempTabs.add(
        GButton(
          icon: Icons.admin_panel_settings,
          text: "Admin",
          iconColor: Colors.orange,
          iconActiveColor: Colors.red,
        ),
      );
    } else if (userState.roles.contains("Moderator")) {
      tempWidgets.add(const ModeratorScreen());
      tempTabs.add(
        GButton(
          icon: Icons.admin_panel_settings,
          text: "Admin",
          iconColor: Colors.orange,
          iconActiveColor: Colors.red,
        ),
      );
    }

    setState(() {
      camera = tempCamera;
      widgetOptions = tempWidgets;
      navTabs = tempTabs;
      doneInitializing = true;
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() {
        userState = Provider.of<UserState>(context, listen: false);
      });

      await updateAll(context);

      initializeElements();
    });
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
                  tabs: navTabs,
                ),
              ),
            ),
          );
  }
}
