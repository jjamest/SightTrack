// import 'package:flutter/material.dart';
// import 'package:sighttrack_app/components/button.dart';
// import 'package:sighttrack_app/navigation_bar.dart';

// class UploadCompleteScreen extends StatelessWidget {
//   const UploadCompleteScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Set background to a clean white
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Congratulations Logo or Icon
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.green.shade100, // Subtle background for the logo
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.check_circle,
//                 color: Colors.green,
//                 size: 100, // Adjust size as needed
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Upload Complete Text
//             const Text(
//               "Upload Complete!",
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Subtext
//             Text(
//               "Your file has been successfully uploaded.",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),

//             CustomButton(
//                 onTap: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CustomNavigationBar(),
//                     ),
//                     (route) => true,
//                   );
//                 },
//                 label: 'Go Back'),
//           ],
//         ),
//       ),
//     );
//   }
// }
