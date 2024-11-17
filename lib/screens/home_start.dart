import 'dart:async';
import 'package:flutter/material.dart';

import 'auth/signup.dart';
import 'auth/login.dart';

class HomeStart extends StatefulWidget {
  const HomeStart({super.key});

  @override
  HomeStartState createState() => HomeStartState();
}

class HomeStartState extends State<HomeStart> {
  final List<String> messages = [
    'Welcome to SightTrack',
    'Track, learn, explore',
    'Nature awaits you',
    'Track your adventures',
    'Discover'
  ];
  int currentIndex = 0;
  String displayedText = "";
  late Timer timer;
  bool showButton = false;
  bool showAuthOptions = false;

  @override
  void initState() {
    super.initState();

    typeText(messages[currentIndex]);

    // Start the timer to switch messages
    timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      setState(() {
        currentIndex = (currentIndex + 1) % messages.length;
        displayedText = "";
      });
      typeText(messages[currentIndex]); // Start typing the next message
    });

    // Show the button after 1 second
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void typeText(String text) {
    displayedText = "";
    for (int i = 0; i <= text.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) {
          setState(() {
            displayedText = text.substring(0, i);
          });
        }
      });
    }
  }

  void onButtonPress() {
    setState(() {
      showButton = false;
      showAuthOptions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Text(
              displayedText,
              textAlign: TextAlign.center,
              softWrap: true,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            left: showAuthOptions
                ? MediaQuery.of(context).size.width * 0.5 - 45
                : 500,
            top: MediaQuery.of(context).size.height * 0.65,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: showAuthOptions ? 1.0 : 0.0,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.blue, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: Theme.of(context).textTheme.labelLarge,
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text("Login"),
                          ),
                          const SizedBox(height: 50),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.blue, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              textStyle: Theme.of(context).textTheme.labelLarge,
                              backgroundColor: Colors.transparent,
                            ),
                            child: const Text("Sign Up"),
                          ),
                        ],
                      ))),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            left:
                showButton ? MediaQuery.of(context).size.width / 2 - 80 : -150,
            top: MediaQuery.of(context).size.height * 0.7,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1000),
              opacity: showButton ? 1.0 : 0.0,
              child: OutlinedButton(
                onPressed: onButtonPress,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
                child: const Text("Start Your Journey"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
