//
// Created by Jason Davidson on 8/28/21.
//

import Foundation
import SwiftyJSON
import UserNotifications

public enum Utilities {
    public static func plistString(_ key: String) -> String {
        let plistDict = NSMutableDictionary(
            contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!
        return plistDict.object(forKey: key) as! String
    }

    public static func plistBool(_ key: String) -> Bool {
        let plistDict = NSMutableDictionary(
            contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!
        return plistDict.object(forKey: key) as! Bool
    }

    public static func log(_ message: Any?) {
        if let logMessage = message as? String {
            NSLog(logMessage)
        } else if let logMessage = message as? NSError {
            NSLog("%@", logMessage)
        } else if let logMessage = message as? JSON {
            NSLog("%@", logMessage.stringValue)
        } else if let logMessage = message as? NSObject {
            NSLog("%@", logMessage)
        }
    }
}
