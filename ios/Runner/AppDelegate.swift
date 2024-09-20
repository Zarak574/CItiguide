import Flutter
import UIKit
import GoogleMaps
import shared_preferences

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAd4rEAQqf58fCJGABqW99teDP9BcuyN08")
    GeneratedPluginRegistrant.register(with: self)
    UserDefaultsPlugin.register(with: self.registrar(forPlugin: "io.flutter.plugins.sharedpreferences"))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions),
  }
}
