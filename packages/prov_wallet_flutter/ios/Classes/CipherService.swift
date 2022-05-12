//
// Created by Jason Davidson on 8/29/21.
//

import Foundation
import LocalAuthentication

class CipherService: NSObject {
    private let v1SecKeyTagBiometry = "io.provenance.wallet.biometry".data(using: .utf8)!
    private let v1SecKeyTagPasscode = "io.provenance.wallet.passcode".data(using: .utf8)!
    private let v1KeyCipher = "cipher"

    private let version = 2
    private let prefKeyVersion = "version"
    private let prefKeyCipherPrefix = "cipher."
    private let prefKeyUseBiometry = "useBiometry"
    private let prefKeyPin = "pin"
    private let secKeyPrefix = "io.provenance.wallet.key."

    private var authContext: LAContext

    let biometryType: BiometryType

    override init() {
        authContext = LAContext()

        var type = BiometryType.unknown

        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if canEvaluate {
            switch authContext.biometryType {
            case LABiometryType.faceID:
                type = .faceId
            case LABiometryType.touchID:
                type = .touchId
            case LABiometryType.none:
                type = .none
            default:
                type = .unknown
            }
        }

        biometryType = type
    }

    func upgrade() async throws {
        let existingVersion = getVersion()
        if existingVersion == 1 {
            try await upgradeV1ToV2()
        }

        UserDefaults.standard.set(version, forKey: prefKeyVersion)
    }

    func getVersion() -> Int {
        var existingVersion = UserDefaults.standard.integer(forKey: prefKeyVersion)
        if existingVersion == 0 {
            if UserDefaults.standard.data(forKey: v1KeyCipher) != nil {
                existingVersion = 1
            } else {
                existingVersion = version
            }
        }

        return existingVersion
    }

    func getBiometryType() -> BiometryType {
        return biometryType
    }

    func getLockScreenEnabled() -> Bool {
        return authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func authenticate(useBiometry: Bool? = nil) async -> Bool {
        let doUseBiometry = useBiometry ?? getUseBiometry()
        let policy = doUseBiometry ? LAPolicy.deviceOwnerAuthenticationWithBiometrics : LAPolicy.deviceOwnerAuthentication

        return await withCheckedContinuation {
            (continuation: CheckedContinuation<Bool, Never>) in authContext.evaluatePolicy(policy, localizedReason: "Authentication") { success, _ in
                    continuation.resume(returning: success)
                }
        }
    }

    func resetAuth() -> Bool {
        authContext.invalidate()
        authContext = LAContext()

        return true
    }

    func encryptKey(id: String, plainText: String) async throws {
        let success = await authenticate()
        if !success {
            throw CipherServiceError(kind: .accessError, message: "Authentication failed")
        }

        let newCipherText = try encrypt(id: id, plainText: plainText)

        saveCipher(id: id, cipher: newCipherText)
    }

    func decryptKey(id: String) async throws -> String {
        let success = await authenticate()
        if !success {
            throw CipherServiceError(kind: .accessError, message: "Authentication failed")
        }

        let cipher = getCipher(id: id)
        let plainText = try decrypt(id: id, cipherText: cipher)

        return plainText
    }

    func removeKey(id: String) throws -> Bool {
        let prefKey = getCipherPrefKey(id: id)
        UserDefaults.standard.removeObject(forKey: prefKey)

        return deleteSecKey(id: id)
    }

    func setUseBiometry(useBiometry: Bool) {
        UserDefaults.standard.set(useBiometry, forKey: prefKeyUseBiometry)
    }

    func setPin(pin: String) throws -> Bool {
        return try setPassword(key: prefKeyPin, value: pin)
    }

    func getPin() -> String? {
        return getPassword(key: prefKeyPin)
    }

    func deletePin() -> Bool {
        return deletePassword(key: prefKeyPin)
    }

    func resetKeys() -> Bool {
        let query = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecUseAuthenticationContext: authContext,
        ] as CFDictionary

        let status = SecItemDelete(query)

        return status == errSecSuccess
    }

    func getUseBiometry() -> Bool {
        return UserDefaults.standard.bool(forKey: prefKeyUseBiometry)
    }

    func setPassword(key: String, value: String) throws -> Bool {
        var error: Unmanaged<CFError>?
        let flags: SecAccessControlCreateFlags = []
        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, &error) else {
            throw CipherServiceError(kind: .accessError, message: "Failed to create access control")
        }

        let exists = passwordExists(key: key)
        if exists {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccessControl as String: access,
                kSecAttrAccount as String: key,
                kSecValueData as String: value.data(using: .utf8)!,
                kSecUseAuthenticationContext as String: authContext,
            ]

            let attributes: [String: Any] = [
                kSecValueData as String: value.data(using: .utf8)!,
            ]

            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

            guard status == errSecSuccess else {
                let message = SecCopyErrorMessageString(status, nil)
                Utilities.log(message)

                throw CipherServiceError(kind: .addSecItem, message: "Could not update item in keychain")
            }
        } else {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccessControl as String: access,
                kSecAttrAccount as String: key,
                kSecValueData as String: value.data(using: .utf8)!,
            ]

            let status = SecItemAdd(query as CFDictionary, nil)

            guard status == errSecSuccess else {
                let message = SecCopyErrorMessageString(status, nil)
                Utilities.log(message)

                throw CipherServiceError(kind: .addSecItem, message: "Could not add item to keychain")
            }
        }

        return true
    }

    private func getPassword(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: authContext,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess {
            guard let data = item as? Data else {
                return nil
            }

            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    private func passwordExists(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        return status == errSecInteractionNotAllowed || status == errSecSuccess
    }

    private func deletePassword(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecUseAuthenticationContext as String: authContext,
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess
    }

    private func deleteAllPasswords() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecUseAuthenticationContext as String: authContext,
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess
    }

    private func getCipherPrefKey(id: String) -> String {
        return "\(prefKeyCipherPrefix)\(id)"
    }

    private func getCipher(id: String) -> Data {
        let prefKey = getCipherPrefKey(id: id)

        return UserDefaults.standard.data(forKey: prefKey) ?? "".data(using: .utf8)!
    }

    private func saveCipher(id: String, cipher: Data) {
        let prefKey = getCipherPrefKey(id: id)

        UserDefaults.standard.set(cipher, forKey: prefKey)
    }

    private func encrypt(id: String, plainText: String) throws -> Data {
        if plainText.isEmpty {
            return "".data(using: .utf8)!
        }

        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        let existingSecKey = loadSecKey(id: id)
        if existingSecKey != nil {
            _ = deleteSecKey(id: id)
        }

        let secKey = try createSecKey(id: id)

        guard let publicKey: SecKey = SecKeyCopyPublicKey(secKey) else {
            throw CipherServiceError(kind: .publicKeyError, message: "Could not create public key for id: \(id)")
        }

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
            throw CipherServiceError(kind: .unsupportedAlgorithm, message: "Encryption algorithm is not supported for id: \(id)")
        }
        var error: Unmanaged<CFError>?

        guard let cipherText = SecKeyCreateEncryptedData(publicKey,
                                                         algorithm,
                                                         plainText.data(using: .utf8)! as CFData,
                                                         &error) as Data?
        else {
            throw error!.takeRetainedValue() as Error
        }

        return cipherText
    }

    private func decrypt(id: String, cipherText: Data) throws -> String {
        if cipherText.isEmpty {
            return ""
        }

        guard let secKey = loadSecKey(id: id) else {
            throw CipherServiceError(kind: .secKeyNotFound, message: "Sec key not found for id: \(id)")
        }

        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
            throw CipherServiceError(kind: .unsupportedAlgorithm, message: "Decryption algorithm is not supported")
        }

        var error: Unmanaged<CFError>?

        guard let data = SecKeyCreateDecryptedData(secKey, algorithm, cipherText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        guard let plainText = String(data: data, encoding: .utf8) else {
            throw CipherServiceError(kind: .dataPersistence, message: "Bad encoding")
        }

        return plainText
    }

    private func getSecKeyTag(id: String) -> Data {
        return (secKeyPrefix + id).data(using: .utf8)!
    }

    private func createSecKey(id: String) throws -> SecKey {
        let flags: SecAccessControlCreateFlags = [
            .privateKeyUsage,
            .userPresence,
        ]

        let tag = getSecKeyTag(id: id)

        guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                           kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                           flags,
                                                           nil)
        else {
            throw CipherServiceError(kind: .accessError, message: "Failed to create access control")
        }

        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag,
                kSecAttrAccessControl as String: access,
            ],
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            let error = error!.takeRetainedValue() as Error
            Utilities.log(error)
            throw error
        }

        return secKey
    }

    private func loadSecKey(id: String) -> SecKey? {
        let tag = getSecKeyTag(id: id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true,
            kSecUseAuthenticationContext as String: authContext,
        ]

        var secKey: SecKey?

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            secKey = (item as! SecKey)
        } else {
            Utilities.log("Did not find sec key. Status: \(status)")
        }

        return secKey
    }

    private func deleteSecKey(id: String) -> Bool {
        let tag = getSecKeyTag(id: id)

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true,
            kSecUseAuthenticationContext as String: authContext,
        ]

        var success = true

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            success = false
            Utilities.log("Failed to delete existing sec key for id: \(id)")
        }

        return success
    }

    private func upgradeV1ToV2() async throws {
        Utilities.log("Upgrading cipher service from V1 to V2")

        let v1Cipher = v1GetCipher()
        let plainText = try v1Decrypt(cipherText: v1Cipher)
        let privateKeys = v1DeserializePrivateKeys(str: plainText)
        for id in privateKeys.keys {
            guard let privateKey = privateKeys[id] else {
                throw CipherServiceError(kind: .upgradeError, message: "V1 private key not found")
            }

            try await encryptKey(id: id, plainText: privateKey)
        }

        Utilities.log("Finished cipher service upgrade")
    }

    private func v1GetCipher() -> Data {
        return UserDefaults.standard.data(forKey: v1KeyCipher) ?? "".data(using: .utf8)!
    }

    private func v1DecryptKey(id: String) throws -> String {
        let cipher = v1GetCipher()
        let serializedKeys = try v1Decrypt(cipherText: cipher)
        let keyDict = v1DeserializePrivateKeys(str: serializedKeys)
        guard let plainText = keyDict[id] else {
            throw CipherServiceError(kind: .accountKeyNotFound, message: "Decrypt failed: account key not found")
        }

        return plainText
    }

    private func v1LoadSecKey() throws -> SecKey {
        let useBiometry = getUseBiometry()
        let tag = useBiometry ? v1SecKeyTagBiometry : v1SecKeyTagPasscode
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecReturnRef as String: true,
            kSecUseAuthenticationContext as String: authContext,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            throw CipherServiceError(kind: .upgradeError, message: "Failed to upgrade key storage")
        }

        if status != errSecSuccess {
            throw CipherServiceError(kind: .secKeyNotFound, message: "Failed to find sec key")
        }

        return (item as! SecKey)
    }

    private func v1Decrypt(cipherText: Data) throws -> String {
        if cipherText.isEmpty {
            return ""
        }

        let secKey = try v1LoadSecKey()

        let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
        guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
            throw CipherServiceError(kind: .unsupportedAlgorithm, message: "Decryption algorithm is not supported")
        }

        var error: Unmanaged<CFError>?

        guard let data = SecKeyCreateDecryptedData(secKey, algorithm, cipherText as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }

        guard let serializedKeys = String(data: data, encoding: .utf8) else {
            throw CipherServiceError(kind: .dataPersistence, message: "Bad encoding")
        }

        return serializedKeys
    }

    private func v1DeserializePrivateKeys(str: String) -> [String: String] {
        var privateKeys = [String: String]()
        for wallet in str.components(separatedBy: ";") {
            let pair = wallet.components(separatedBy: "=")
            if pair.count == 2 {
                let key = pair[0]
                let value = pair[1]
                privateKeys[key] = value
            }
        }

        return privateKeys
    }
}
