import Flutter
import Foundation

public class SwiftProvWalletFlutterPlugin: NSObject, FlutterPlugin {
    var flutterChannel: FlutterMethodChannel?
    
	public static func register(with registrar: FlutterPluginRegistrar) {
		let channel = FlutterMethodChannel(name: "prov_wallet_flutter", binaryMessenger: registrar.messenger())
		  
		let instance = SwiftProvWalletFlutterPlugin()
		instance.flutterChannel = channel

		registrar.addMethodCallDelegate(instance, channel: channel)
	}
    
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		if (call.method == "getPlatformVersion") {
			result("iOS " + UIDevice.current.systemVersion)
		} else if (call.method == "biometryAuth") {
			CipherService.biometryAuth({ (success) in result(success) })
		} else if (call.method == "resetAuth") {
			CipherService.resetAuth()
		} else if (call.method == "encryptKey") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				guard let id = argsFormatted?["id"] as? String else {
					throw PluginError(kind: .invalidArgument, message: "id is required")
				}
				guard let privateKey = argsFormatted?["private_key"] as? String else {
					throw PluginError(kind: .invalidArgument, message: "privateKey is required")
				}
				let useBiometry = argsFormatted?["use_biometry"] as? Bool
			
				try CipherService.encryptKey(id: id, plainText: privateKey, useBiometry: useBiometry)
				
				success = true
			} catch {
				showError(title: "Encrypt", error: error)
			}
			
			result(success)
		} else if (call.method == "decryptKey") {
			var key: String?
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				guard let id = argsFormatted?["id"] as? String else {
					throw PluginError(kind: .invalidArgument, message: "id is required")
				}
				
				key = try CipherService.decryptKey(id: id)
			} catch {
				showError(title: "Decrypt", error: error)
			}
			
			result(key)
		} else if (call.method == "removeKey") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				guard let id = argsFormatted?["id"] as? String else {
					throw PluginError(kind: .invalidArgument, message: "id is required")
				}
				
				success = try CipherService.removeKey(id: id)
			} catch {
				showError(title: "Remove Key", error: error)
			}
			
			result(success)
		} else if (call.method == "resetKeys") {
			CipherService.resetKeys()
			
			result(true)
		} else if (call.method == "getUseBiometry") {
			let useBiometry = CipherService.getUseBiometry()
			
			result(useBiometry)
		} else if (call.method == "setUseBiometry") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				let useBiometry = argsFormatted?["use_biometry"] as? Bool ?? true
				
				try CipherService.setUseBiometry(useBiometry: useBiometry)
				success = true
			} catch {
				showError(title: "Set Biometry", error: error)
			}
			
			result(success)
		} else if (call.method == "getPin") {
			var value: String?
			
			do {
				value = try CipherService.getPin()
			} catch {
				showError(title: "Get pin", error: error)
			}
			
			result(value)
		} else if (call.method == "setPin") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				guard let pin = argsFormatted?["pin"] as? String else {
					throw PluginError(kind: .invalidArgument, message: "pin is required")
				}
			
				success = try CipherService.setPin(pin: pin)
				
			} catch {
				showError(title: "Set pin", error: error)
			}
			
			result(success)
		} else if (call.method == "deletePin") {
			let success = CipherService.deletePin()
		
			result(success)
		}
	}
	
	private func showError(title: String, error: Error) {
		var message: String
		if (error is ProvenanceWalletError) {
			message = (error as! ProvenanceWalletError).message
		} else if (error is PluginError) {
			message = (error as! PluginError).message
		} else {
			message = error.localizedDescription
		}
		
		ErrorHandler.show(title: title, message: message, completionHandler: nil)
	}
}

struct PluginError: Error {
	enum ErrorKind {
		case invalidArgument
	}
	let kind: ErrorKind
	let message: String
}
