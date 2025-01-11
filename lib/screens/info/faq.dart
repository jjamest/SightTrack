import "package:flutter/material.dart";

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF00897B); // Greenish teal color

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            FAQTile(
              question: "What is the purpose of SightTrack?",
              answer:
                  "The purpose of SightTrack is to empower individuals worldwide to capture and share pictures of different animal species, fostering a global awareness of the locations and habitats of various species. By building a comprehensive and user-generated database of wildlife sightings, SightTrack aims to build a global community interested in biodiversity and animal conservation by sharing real-time information about wildlife sightings.",
              themeColor: themeColor,
            ),
            FAQTile(
              question: "How does SightTrack work?",
              answer:
                  "SightTrack operates by allowing users to take pictures of animal species they encounter and upload these images to the app. The uploaded photos include metadata such as the date, time, and location of the sighting, which helps in tracking and mapping the presence of different species across the globe. The app’s interface is user-friendly, enabling users to easily browse through the sightings and search for specific species or locations. It also offers features like species identification, sighting history, and community engagement tools to foster collaboration among users.",
              themeColor: themeColor,
            ),
            FAQTile(
              question: "How can I ensure my privacy is secure?",
              answer:
                  "SightTrack prioritizes user privacy by implementing several security measures. Users can control the visibility of their uploads and personal information through the app’s privacy settings. The app does not share personal data with third parties without explicit consent from the user. Additionally, SightTrack uses encryption to protect data transmission and storage, ensuring that personal information and sighting details are kept secure. Users are encouraged to review the app’s privacy policy and adjust settings according to their comfort level.",
              themeColor: themeColor,
            ),
            FAQTile(
              question: "How do you use my data?",
              answer:
                  "SightTrack uses your data to enhance the app’s functionality and user experience. The data collected, including photos and sighting information, is primarily used to create a comprehensive database of wildlife sightings. This information is then used for research, conservation efforts, and to provide users with insights about animal locations and behaviors. Aggregate data may be shared with conservation organizations to support their work, but personal identifiers are kept confidential unless the user opts to share them. The app also uses data analytics to improve its features and performance.",
              themeColor: themeColor,
            ),
            FAQTile(
              question: "Can I use SightTrack offline?",
              answer:
                  "SightTrack has limited offline functionality. For full functionality, including uploading new sightings and accessing real-time data, an internet connection is required. While users cannot upload pictures or access the latest sighting data without an internet connection, they can still view already uploaded pictures on the map. This allows users to review previous sightings and explore the map even when they are in areas without internet access. ",
              themeColor: themeColor,
            ),
          ],
        ),
      ),
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  final Color themeColor;

  const FAQTile({
    super.key,
    required this.question,
    required this.answer,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
