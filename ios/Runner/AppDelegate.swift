import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

      
      let registrar = self.registrar(forPlugin: "CipherService")
      
      SwiftProvWalletFlutterPlugin.register(with: registrar!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
