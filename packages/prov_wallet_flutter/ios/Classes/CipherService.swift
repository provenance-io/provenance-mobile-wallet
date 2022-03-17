//
// Created by Jason Davidson on 8/29/21.
//

import Foundation
import LocalAuthentication

class CipherService: NSObject {
	static let keyCipher = "cipher"
	static let keyUseBiometry = "useBiometry"
	static let keyPin = "pin"
	
	static let secKeyTagBiometry = "io.provenance.wallet.biometry".data(using: .utf8)!
	static let secKeyTagPasscode = "io.provenance.wallet.passcode".data(using: .utf8)!
	
	static var authContext = LAContext()
	
	static func biometryAuth(_ result: @escaping (Bool) -> Void) {
		authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication", reply: { (success, error) in result(success) })
	}
	
	static func resetAuth() {
		authContext.invalidate()
		authContext = LAContext()
	}
	
	static func encryptKey(id: String, plainText: String, useBiometry: Bool?) throws {
		let doUseBiometry = useBiometry ?? getUseBiometry()
		
		let cipher = getCipher()
		let serializedKeys = try decrypt(cipherText: cipher)
		var keyDict = deserializePrivateKeys(str: serializedKeys)
		
		keyDict[id] = plainText
		let newSerializedKeys = serializePrivateKeys(dictionary: keyDict)
		let newCipherText = try encrypt(plainText: newSerializedKeys, useBiometry: doUseBiometry)
		
		saveCipher(cipher: newCipherText)
		saveUseBiometry(useBiometry: doUseBiometry)
	}
	
	static func decryptKey(id: String) throws -> String {
		let cipher = getCipher()
		let serializedKeys = try decrypt(cipherText: cipher)
		let keyDict = deserializePrivateKeys(str: serializedKeys)
		guard let plainText = keyDict[id] else {
			throw ProvenanceWalletError(kind: .walletKeyNotFound, message: "Decrypt failed: wallet key not found")
		}
		
		return plainText
	}
	
	static func removeKey(id: String) throws -> Bool {
		let cipher = getCipher()
		let serializedKeys = try decrypt(cipherText: cipher)
		var keyDict = deserializePrivateKeys(str: serializedKeys)
		let value = keyDict.removeValue(forKey: id)
		
		var success = false
		if (value != nil) {
			let newSerializedKeys = serializePrivateKeys(dictionary: keyDict)
			let newCipherText = try encrypt(plainText: newSerializedKeys)
			
			saveCipher(cipher: newCipherText)
			success = true
		}
		
		return success
	}
	
	static func setUseBiometry(useBiometry: Bool) throws {
		let current = getUseBiometry()
		if (current != useBiometry) {
			let cipher = getCipher()
			let serializedKeys = try decrypt(cipherText: cipher)
			
			let newCipher = try encrypt(plainText: serializedKeys, useBiometry: useBiometry)
			saveCipher(cipher: newCipher)
			saveUseBiometry(useBiometry: useBiometry)
		}
	}
	
	static func setPin(pin: String) throws -> Bool {
		return try setPassword(key: keyPin, value: pin)
	}
	
	static func getPin() throws -> String? {
		return try getPassword(key: keyPin)
	}
	
	static func deletePin() -> Bool {
		return deletePassword(key: keyPin)
	}
	
	static func resetKeys() {
		UserDefaults.standard.removeObject(forKey: keyCipher)
	}
	
	static func getUseBiometry() -> Bool {
		return UserDefaults.standard.bool(forKey: keyUseBiometry)
	}
	
	private static func setPassword(key: String, value: String) throws -> Bool {
		var error: Unmanaged<CFError>?
		let flags: SecAccessControlCreateFlags = []
		guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, flags, &error) else {
			throw ProvenanceWalletError(kind: .accessError, message: "Failed to create access control")
		}
		
		let exists = passwordExists(key: key)
		if (exists) {
			let query: [String: Any] = [
				kSecClass as String: kSecClassGenericPassword,
				kSecAttrAccessControl as String: access,
				kSecAttrAccount as String: key,
				kSecValueData as String: value.data(using: .utf8)!,
				kSecUseAuthenticationContext as String: authContext,
			]
			
			let attributes: [String: Any] = [
				kSecValueData as String: value.data(using: .utf8)!
			]
			
			let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
			
			guard status == errSecSuccess else {
				let message = SecCopyErrorMessageString(status, nil)
				Utilities.log(message)
				
				throw ProvenanceWalletError(kind: .addSecItem, message: "Could not update item in keychain")
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
				
				throw ProvenanceWalletError(kind: .addSecItem, message: "Could not add item to keychain")
			}
		}
		
		return true
	}
	
	private static func getPassword(key: String) throws -> String? {
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
	
	private static func passwordExists(key: String) -> Bool {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail
		]
		
		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		
		return status == errSecInteractionNotAllowed || status == errSecSuccess
	}
	
	private static func deletePassword(key: String) -> Bool {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			kSecUseAuthenticationContext as String: authContext,
		]
		
		let status = SecItemDelete(query as CFDictionary)
		
		return status == errSecSuccess
	}
	
	private static func deleteAllPasswords() -> Bool {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecUseAuthenticationContext as String: authContext,
		]
		
		let status = SecItemDelete(query as CFDictionary)
		
		return status == errSecSuccess
	}
	
	private static func getCipher() -> Data {
		return UserDefaults.standard.data(forKey: keyCipher) ?? "".data(using: .utf8)!
	}

	private static func saveCipher(cipher: Data) {
		UserDefaults.standard.set(cipher, forKey: keyCipher)
	}
	
	private static func saveUseBiometry(useBiometry: Bool) {
		UserDefaults.standard.set(useBiometry, forKey: keyUseBiometry)
	}
	
	private static func encrypt(plainText: String, useBiometry: Bool = getUseBiometry()) throws -> Data {
		if (plainText.isEmpty) {
			return "".data(using: .utf8)!
		}
		
		let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
		let secKey = try loadSecKey(useBiometry: useBiometry)
		
		guard let publicKey: SecKey = SecKeyCopyPublicKey(secKey) else {
			throw ProvenanceWalletError(kind: .publicKeyError, message: "Could not create public key")
		}

		guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
			throw ProvenanceWalletError(kind: .unsupportedAlgorithm, message: "Encryption algorithm is not supported")
		}
		var error: Unmanaged<CFError>?

		guard let cipherText = SecKeyCreateEncryptedData(publicKey,
		                                                 algorithm,
		                                                 plainText.data(using: .utf8)! as CFData,
		                                                 &error) as Data? else {
			throw error!.takeRetainedValue() as Error
		}
		
		return cipherText
	}

	private static func decrypt(cipherText: Data) throws -> String {
		if (cipherText.isEmpty) {
			return ""
		}
		
		let secKey = try loadSecKey()

		let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
		guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
			throw ProvenanceWalletError(kind: .unsupportedAlgorithm, message: "Decryption algorithm is not supported")
		}

		var error: Unmanaged<CFError>?

		guard let data = SecKeyCreateDecryptedData(secKey, algorithm, cipherText as CFData, &error) as Data? else {
			throw error!.takeRetainedValue() as Error
		}
		
		guard let serializedKeys = String(data: data, encoding: .utf8) else {
			throw ProvenanceWalletError(kind: .dataPersistence, message: "Bad encoding")
		}
		
		return serializedKeys
	}

	private static func createSecKey(useBiometry: Bool) throws {
		var flags: SecAccessControlCreateFlags = [
			.privateKeyUsage,
		]
		
		var tag: Data
		if (useBiometry) {
			tag = secKeyTagBiometry
			flags.insert(.biometryAny)
		} else {
			flags.insert(.devicePasscode)
			tag = secKeyTagPasscode
		}

		guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
		                                             kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     flags,
														   nil) else {
			throw ProvenanceWalletError(kind: .accessError, message: "Failed to create access control")
		}
		
		let attributes: [String: Any] = [
			kSecAttrKeyType as String: kSecAttrKeyTypeEC,
			kSecAttrKeySizeInBits as String: 256,
			kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
			kSecPrivateKeyAttrs as String: [
				kSecAttrIsPermanent as String: true,
				kSecAttrApplicationTag as String: tag,
				kSecAttrAccessControl as String: access
			]
		]

		var error: Unmanaged<CFError>?
		guard let _ = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
			let error = error!.takeRetainedValue() as Error
			Utilities.log(error)
			throw error
		}
	}

	private static func loadSecKey(useBiometry: Bool = getUseBiometry()) throws -> SecKey {
		let tag = useBiometry ? secKeyTagBiometry : secKeyTagPasscode
		let query: [String: Any] = [
			kSecClass as String: kSecClassKey,
			kSecAttrApplicationTag as String: tag,
			kSecAttrKeyType as String: kSecAttrKeyTypeEC,
			kSecReturnRef as String: true,
			kSecUseAuthenticationContext as String: authContext,
		]

		var item: CFTypeRef?
		var status = SecItemCopyMatching(query as CFDictionary, &item)
		if (status == errSecItemNotFound) {
			try createSecKey(useBiometry: true)
			try createSecKey(useBiometry: false)
			status = SecItemCopyMatching(query as CFDictionary, &item)
		}
		
		if (status != errSecSuccess) {
			throw ProvenanceWalletError(kind: .secKeyNotFound, message: "Failed to find sec key")
		}
		
		return (item as! SecKey)
	}
	
	private static func deserializePrivateKeys(str: String) -> Dictionary<String, String> {
		var privateKeys = Dictionary<String, String>()
		for wallet in str.components(separatedBy: ";") {
			let pair =  wallet.components(separatedBy: "=")
			if (pair.count == 2) {
				let key = pair[0]
				let value = pair[1]
				privateKeys[key] = value
			}
		}
		
		return privateKeys
	}
	
	private static func serializePrivateKeys(dictionary: Dictionary<String, String>) -> String {
		return dictionary.map { (key, value) -> String in
			return "\(key)=\(value)"
		}.joined(separator: ";")
	}
}
