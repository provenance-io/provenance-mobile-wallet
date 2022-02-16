import Foundation

struct ProvenanceWalletError: Error {
	enum ErrorKind {
		case accessError
		case dataPersistence
		case unsupportedAlgorithm
		case cipherNotFound
		case keyNotFound
		case publicKeyError
		case walletSaveError
	}
	let kind: ErrorKind
	let message: String
	let messages: [String]?
	let underlyingError: Error?
}
