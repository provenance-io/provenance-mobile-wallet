import Flutter

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
		} else if (call.method == "encryptKey") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				guard let id = argsFormatted?["id"] as? String else {
					throw PluginError.invalidArgument("id is required")
				}
				guard let privateKey = argsFormatted?["private_key"] as? String else {
					throw PluginError.invalidArgument("privateKey is required")
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
					throw PluginError.invalidArgument("id is required")
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
					throw PluginError.invalidArgument("id is required")
				}
				
				success = try CipherService.removeKey(id: id)
			} catch {
				showError(title: "Remove Key", error: error)
			}
			
			result(success)
		} else if (call.method == "getUseBiometry") {
			let useBiometry = CipherService.getUseBiometry()
			
			result(useBiometry)
		} else if (call.method == "setUseBiometry") {
			var success = false
			
			do {
				let argsFormatted = call.arguments as? Dictionary<String, Any>
				let useBiometry = argsFormatted?["use_biometry"] as? Bool ?? true
				
				success = try CipherService.setUseBiometry(useBiometry: useBiometry)
			} catch {
				showError(title: "Set Biometry", error: error)
			}
			
			result(success)
		} else if (call.method == "reset") {
			let success = CipherService.reset()
			
			result(success)
		}
	}
	
	private func showError(title: String, error: Error) {
		let message = error is ProvenanceWalletError ? (error as! ProvenanceWalletError).message : error.localizedDescription
		ErrorHandler.show(title: title, message: message, completionHandler: nil)
	}
}

enum PluginError: Error {
	case invalidArgument(String)
}
