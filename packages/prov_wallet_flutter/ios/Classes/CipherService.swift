//
// Created by Jason Davidson on 8/29/21.
//

import Foundation

class CipherService: NSObject {
	
	static let secKeyName = "main"
	static let cipherKeyName = "cipher"
	static let useBiometryKeyName = "useBiometry"
	
	static func encryptKey(id: String, plainText: String, useBiometry: Bool?) throws {
		var keyDict: Dictionary<String, String>
		
		let cipher = tryGetCipher()
		if (cipher == nil) {
			let _ = try createSecKey(useBiometry: useBiometry)
			keyDict = Dictionary<String, String>()
		} else {
			let serializedKeys = try decrypt(cipherText: cipher!)
			keyDict = deserializePrivateKeys(str: serializedKeys)
			
			if (useBiometry != getUseBiometry()) {
				let _ = try createSecKey(useBiometry: useBiometry)
			}
		}
		
		keyDict[id] = plainText
		let newSerializedKeys = serializePrivateKeys(dictionary: keyDict)
		let newCipherText = try encrypt(plainText: newSerializedKeys)
		
		setCipher(cipher: newCipherText)
	}
	
	static func decryptKey(id: String) throws -> String {
		let cipher = try getCipher()
		let serializedKeys = try decrypt(cipherText: cipher)
		let keyDict = deserializePrivateKeys(str: serializedKeys)
		guard let plainText = keyDict[id] else {
			throw ProvenanceWalletError(kind: .keyNotFound,
										message: "Key not found for id \(id)",
										messages: nil,
										underlyingError: nil)
		}
		
		return plainText
	}
	
	static func getUseBiometry() -> Bool {
		return UserDefaults.standard.bool(forKey: useBiometryKeyName)
	}
	
	static func setUseBiometry(useBiometry: Bool) throws -> Bool {
		var success = false
		
		let current = getUseBiometry()
		if (current != useBiometry) {
			let cipher = try getCipher()
			let serializedKeys = try decrypt(cipherText: cipher)
			let created = try createSecKey(useBiometry: useBiometry)
			if (created) {
				let cipher = try encrypt(plainText: serializedKeys)
				setCipher(cipher: cipher)
				success = true
			} else {
				Utilities.log("Set use biometry failed. Could not create sec key.")
			}
		}
		
		return success
	}
	
	private static func getCipher() throws -> Data {
		guard let cipher = UserDefaults.standard.data(forKey: cipherKeyName) else {
			throw ProvenanceWalletError(kind: .cipherNotFound,
										message: "Cipher not found.",
										messages: nil,
										underlyingError: nil)
		}
		
		return cipher
	}
	
	private static func tryGetCipher() -> Data? {
		return UserDefaults.standard.data(forKey: cipherKeyName)
	}
	
	
	private static func setCipher(cipher: Data) {
		UserDefaults.standard.set(cipher, forKey: cipherKeyName)
	}
	
	private static func encrypt(plainText: String) throws -> Data {
		let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
		guard let secKey = loadSecKey() else {
			throw ProvenanceWalletError(kind: .keyNotFound, message: "\(secKeyName) not found", messages: nil,
			                            underlyingError: nil)
		}
		guard let publicKey: SecKey = SecKeyCopyPublicKey(secKey) else {
			throw ProvenanceWalletError(kind: .publicKeyError, message: "Could not create public key", messages: nil,
			                            underlyingError: nil)
		}

		guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, algorithm) else {
			throw ProvenanceWalletError(kind: .unsupportedAlgorithm, message: "Encryption Algorithm is not supported",
			                            messages: nil, underlyingError: nil)
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
		
		guard let secKey = loadSecKey() else {
			throw ProvenanceWalletError(kind: .keyNotFound, message: "\(secKeyName) not found", messages: nil,
			                            underlyingError: nil)
		}

		let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
		guard SecKeyIsAlgorithmSupported(secKey, .decrypt, algorithm) else {
			throw ProvenanceWalletError(kind: .unsupportedAlgorithm, message: "Decryption Algorithm is not supported",
			                            messages: nil, underlyingError: nil)
		}

		var error: Unmanaged<CFError>?

		guard let data = SecKeyCreateDecryptedData(secKey, algorithm, cipherText as CFData,
		                                                &error) as Data? else {
			throw error!.takeRetainedValue() as Error
		}
		
		guard let serializedKeys = String(data: data, encoding: .utf8) else {
			throw ProvenanceWalletError(kind: .dataPersistence,
										message: "Bad encoding",
										messages: nil, underlyingError: nil)
		}
		
		return serializedKeys
	}

	/**
	 
	 - Returns: private key, public key tuple
	 - Throws: cipher errors
	 */
	static func createSecKey(useBiometry: Bool?) throws -> Bool {
		let secKey = loadSecKey()
		if (secKey != nil) {
			let _ = deleteSecKey()
		}
		
		var flags: SecAccessControlCreateFlags = [
			.privateKeyUsage,
		]
		
		let doUseBiometry = useBiometry ?? CipherService.getUseBiometry()
		if (doUseBiometry) {
			flags.insert(.biometryAny)
		} else {
			flags.insert(.devicePasscode)
		}

		guard let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
		                                             kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     flags,
														   nil) else {
			throw ProvenanceWalletError(kind: .accessError, message: "Failed to create access control", messages: nil, underlyingError: nil)
		}
		
		let tag = secKeyName.data(using: .utf8)!
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
		
		let success = testDecrypt()
		if (success) {
			UserDefaults.standard.set(useBiometry, forKey: useBiometryKeyName)
		} else {
			let _ = deleteSecKey()
		}
		
		return success
	}
	
	private static func testDecrypt() -> Bool {
		var success = false
		
		do {
			let expectedValue = "test"
			let testCipher = try encrypt(plainText: expectedValue)
			let actualValue = try decrypt(cipherText: testCipher)
			success = expectedValue == actualValue
		} catch {
			Utilities.log(error)
		}
		
		return success
	}

	private static func loadSecKey() -> SecKey? {
		let tag = secKeyName.data(using: .utf8)!
		let query: [String: Any] = [
			kSecClass as String: kSecClassKey,
			kSecAttrApplicationTag as String: tag,
			kSecAttrKeyType as String: kSecAttrKeyTypeEC,
			kSecReturnRef as String: true
		]

		var item: CFTypeRef?
		let status = SecItemCopyMatching(query as CFDictionary, &item)
		guard status == errSecSuccess else {
			return nil
		}
		return (item as! SecKey)
	}
	
	private static func deleteSecKey() -> Bool {
		let tag = secKeyName.data(using: .utf8)!
		
		let query: [String: Any] = [
			kSecClass as String: kSecClassKey,
			kSecAttrApplicationTag as String: tag,
			kSecAttrKeyType as String: kSecAttrKeyTypeEC,
		]

		let status = SecItemDelete(query as CFDictionary)
		
		if (status != errSecSuccess) {
			let message = SecCopyErrorMessageString(status, nil)
			Utilities.log(message)
		}

		return status == errSecSuccess
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
