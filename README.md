# SightTrack

### A Flutter-based iOS app for monitoring biodiversity and environmental changes through real-time animal sighting tracking.

---

## 📸 Overview

**SightTrack** is a powerful and intuitive application designed to help users capture and record animal sightings. By allowing users to take photos of animals and logging key details such as time, location, and species, SightTrack provides valuable insights into biodiversity and environmental shifts. 

Key features include:
- Real-time photo capture and sighting tracking.
- AI-based species recognition to analyze animal sightings.
- Interactive map for visualizing recorded sighting locations.
- Comprehensive sighting logs with time, location, and photo metadata.

## 🌍 Purpose

SightTrack aims to contribute to environmental awareness and research by:
- Tracking biodiversity changes over time.
- Providing a convenient tool for citizen scientists, researchers, and wildlife enthusiasts.
- Facilitating data collection for ecological studies and conservation efforts.

---

## 🚀 Features

1. **Photo Capture**  
   - Take photos directly within the app using a custom camera interface.
   - Upload photos to identify animal species using AI.

2. **Species Recognition**  
   - Automatically analyze and recognize species in uploaded photos.

3. **Interactive Map**  
   - Display sighting locations as markers on a Google Map.
   - Click markers to view sighting details.

4. **User Profiles**  
   - Secure authentication with AWS Cognito.
   - Personalized dashboard for managing user sightings.

5. **Real-Time Tracking**  
   - Log sighting data (time, location, and photo metadata).
   - Monitor environmental changes over time.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)  
- **Authentication:** AWS Cognito with Amplify  
- **Backend:** AWS Lambda and API Gateway
- **Data Storage:** AWS S3 (for photos)  and Dynamo for miscellaneous
- **AI Integration:** AWS Rekognition for species identification  
- **Maps:** Google Maps API  

---

## 📦 Installation

### Prerequisites
- Flutter SDK installed ([Get Flutter](https://flutter.dev/docs/get-started/install)).
- Xcode installed on macOS.
- AWS Amplify CLI installed ([Get Amplify CLI](https://docs.amplify.aws/cli/)).

### Steps
1. **Clone the Repository**  
   ```bash
   git clone https://github.com/your-username/sighttrack.git
   cd sighttrack
   ```

2. **Install Dependencies**  
   ```bash
   flutter pub get
   ```

3. **Configure Amplify**  
   - Run `amplify init` to initialize your Amplify project.
   - Add authentication:  
     ```bash
     amplify add auth
     ```
   - Follow the CLI prompts to configure AWS Cognito.

4. **Run the App**  
   - Open the project in Xcode and select your iOS device/simulator.
   - Run the app:  
     ```bash
     flutter run
     ```

---

## 🔧 Configuration

### AWS Integration
1. **Set Up AWS S3**  
   - Create an S3 bucket for storing user-uploaded photos.
   - Update the bucket name in the app's configuration files.

2. **Configure Lambda**  
   - Deploy an AWS Lambda function for species recognition.
   - Connect Lambda to AWS Rekognition for processing uploaded photos.

3. **Amplify Push**  
   - After configuring S3, Lambda, and other resources, push the changes to AWS:  
     ```bash
     amplify push
     ```

---

## 📊 Data Flow

1. **User uploads a photo.**  
2. The photo is sent to AWS S3.  
3. An AWS Lambda function triggers species recognition using AWS Rekognition.  
4. Recognized data is returned to the app and stored in the database.  
5. The sighting is displayed on the interactive map with metadata.

---

## 🧪 Testing

- Use Flutter's built-in testing framework for widget and integration tests.
- Debug AI integration and map features using in-app logging.

---

## 📃 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## 📬 Feedback and Contributions

We welcome contributions and suggestions! Feel free to:
- Open an issue for bugs or feature requests.
- Fork the repository and submit a pull request.

---

## 🙌 Acknowledgments

- Flutter team for the excellent framework.
- AWS for their robust cloud services.
- Amplify for simplifying backend integration.
