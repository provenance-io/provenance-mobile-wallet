//
// Created by Jason Davidson on 8/28/21.
//

import Foundation
import UserNotifications
import UIKit

public class Utilities {
	public static func plistString(_ key: String) -> String {
		let plistDict: NSMutableDictionary = NSMutableDictionary(
				contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!
		return plistDict.object(forKey: key) as! String
	}

	public static func plistBool(_ key: String) -> Bool {
		let plistDict: NSMutableDictionary = NSMutableDictionary(
				contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!
		return plistDict.object(forKey: key) as! Bool
	}
	
	public static func log(_ message: Any?) -> Void {
		if let logMessage = message as? String {
			NSLog(logMessage)
		} else if let logMessage = message as? NSError {
			NSLog("%@", logMessage)		
		} else if let logMessage = message as? NSObject {
			NSLog("%@", logMessage)
		}

	}

	static func showAlert(title: String, message: String, completionHandler: (() -> Void)?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default) { action in
			if let handler = completionHandler {
				handler()
			}
		}
		alertController.addAction(okAction)
		UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
	}
}
