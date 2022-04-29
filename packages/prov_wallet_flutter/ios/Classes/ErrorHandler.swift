
import Foundation
import UIKit

class ErrorHandler {
    static func show(title: String, message: String, completionHandler: ((Bool) -> Void)?) {
        Utilities.log("ErrorHandler showing \(title) \(message)")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let handler = completionHandler {
                handler(true)
            }
        }
        alertController.addAction(okAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
