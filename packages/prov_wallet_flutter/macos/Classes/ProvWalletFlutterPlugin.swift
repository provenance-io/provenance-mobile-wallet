import Cocoa
import FlutterMacOS

public class ProvWalletFlutterPlugin: NSObject, FlutterPlugin {
    var flutterChannel: FlutterMethodChannel?
    let cipherService: CipherService
    let upgradeTask: Task<Void, Error>

    override public init() {
        let service = CipherService()
        cipherService = service
        upgradeTask = Task {
            try await service.upgrade()
        }
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "prov_wallet_flutter", binaryMessenger: registrar.messenger)
        let instance = ProvWalletFlutterPlugin()
        instance.flutterChannel = channel

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            var value: Any?

            do {
                try await upgradeTask.value

                if call.method == "getPlatformVersion" {
                    value = "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
                } else if call.method == "getBiometryType" {
                    let type = cipherService.biometryType
                    value = type.rawValue
                } else if call.method == "authenticateBiometry" {
                    value = await cipherService.authenticate()
                } else if call.method == "getLockScreenEnabled" {
                    value = cipherService.getLockScreenEnabled()
                } else if call.method == "resetAuth" {
                    value = cipherService.resetAuth()
                } else if call.method == "encryptKey" {
                    let argsFormatted = call.arguments as? [String: Any]
                    guard let id = argsFormatted?["id"] as? String else {
                        throw CipherServiceError(kind: .invalidArgument, message: "id is required")
                    }
                    guard let privateKey = argsFormatted?["private_key"] as? String else {
                        throw CipherServiceError(kind: .invalidArgument, message: "privateKey is required")
                    }

                    try await cipherService.encryptKey(id: id, plainText: privateKey)

                    value = true
                } else if call.method == "decryptKey" {
                    let argsFormatted = call.arguments as? [String: Any]
                    guard let id = argsFormatted?["id"] as? String else {
                        throw CipherServiceError(kind: .invalidArgument, message: "id is required")
                    }

                    value = try await cipherService.decryptKey(id: id)
                } else if call.method == "removeKey" {
                    let argsFormatted = call.arguments as? [String: Any]
                    guard let id = argsFormatted?["id"] as? String else {
                        throw CipherServiceError(kind: .invalidArgument, message: "id is required")
                    }

                    value = try cipherService.removeKey(id: id)
                } else if call.method == "resetKeys" {
                    value = cipherService.resetKeys()
                } else if call.method == "getUseBiometry" {
                    value = cipherService.getUseBiometry()
                } else if call.method == "setUseBiometry" {
                    let argsFormatted = call.arguments as? [String: Any]
                    let useBiometry = argsFormatted?["use_biometry"] as? Bool ?? true

                    cipherService.setUseBiometry(useBiometry: useBiometry)
                    value = true
                } else if call.method == "getPin" {
                    value = cipherService.getPin()
                } else if call.method == "setPin" {
                    let argsFormatted = call.arguments as? [String: Any]
                    guard let pin = argsFormatted?["pin"] as? String else {
                        throw CipherServiceError(kind: .invalidArgument, message: "pin is required")
                    }

                    value = try cipherService.setPin(pin: pin)
                } else if call.method == "deletePin" {
                    value = cipherService.deletePin()
                }
            } catch {
                Utilities.log("Plugin error: \(error)")
                value = getFlutterError(error: error)
            }

            let ret = value

            await MainActor.run {
                result(ret)
            }
        }
    }

    private func getFlutterError(error: Error) -> FlutterError {
        var code: String
        var message: String
        var details: Error?

        if error is CipherServiceError {
            let provError = error as! CipherServiceError
            code = String(describing: provError.kind)
            message = provError.message
        } else {
            code = String(describing: CipherServiceError.CipherServiceErrorCode.unknown)
            message = error.localizedDescription
            details = error
        }

        return FlutterError(code: code, message: message, details: details)
    }
}
