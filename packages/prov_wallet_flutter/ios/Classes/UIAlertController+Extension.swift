//
// Created by Jason Davidson on 8/29/21.
//

import Foundation
import UIKit

extension UIAlertController {
	func withCloseButton(title: String = "Close", onClose: (() -> Void)? = nil ) -> UIAlertController {
		addAction(UIAlertAction(title: title, style: .cancel) { _ in onClose?() } )
		return self
	}

	static func showShouldStart(from controller: UIViewController, clientName: String, onStart: @escaping () -> Void, onClose: @escaping () -> Void) {
		let alert = UIAlertController(title: "Request to start a session", message: clientName, preferredStyle: .alert)
		let startAction = UIAlertAction(title: "Start", style: .default) { _ in onStart() }
		alert.addAction(startAction)
		controller.present(alert.withCloseButton(onClose: onClose), animated: true)
	}

	static func showFailedToConnect(from controller: UIViewController) {
		let alert = UIAlertController(title: "Failed to connect", message: nil, preferredStyle: .alert)
		controller.present(alert.withCloseButton(), animated: true)
	}

	static func showDisconnected(from controller: UIViewController) {
		let alert = UIAlertController(title: "Did disconnect", message: nil, preferredStyle: .alert)
		controller.present(alert.withCloseButton(), animated: true)
	}

	static func showShouldSign(from controller: UIViewController, title: String, message: String, onSign: @escaping () -> Void, onCancel: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let startAction = UIAlertAction(title: "Sign", style: .default) { _ in onSign() }
		alert.addAction(startAction)
		controller.present(alert.withCloseButton(title: "Reject", onClose: onCancel), animated: true)
	}

	static func showShouldSend(from controller: UIViewController, title: String, message: String, onSend: @escaping () -> Void, onCancel: @escaping () -> Void) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let startAction = UIAlertAction(title: "Broadcast", style: .default) { _ in onSend() }
		alert.addAction(startAction)
		controller.present(alert.withCloseButton(title: "Reject", onClose: onCancel), animated: true)
	}

}

