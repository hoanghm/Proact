import Flutter
import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCam9rkqPGIIIaWzGtl4LGO_MD7H0cIrAY")  // Add this line!
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
