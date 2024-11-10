import Flutter
import UIKit
import GoogleMaps
// import GeneratedPluginRegistrant

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)  // Ensure this is here
    GMSServices.provideAPIKey("AIzaSyCHrNqlYgZANyZqRYKHIs-5WnFJSEJlV8Y")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
