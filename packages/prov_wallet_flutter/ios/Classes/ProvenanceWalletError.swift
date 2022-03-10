import Foundation

struct ProvenanceWalletError: Error {
	enum ErrorKind {
		case accessError
		case addSecItem
		case dataPersistence
		case unsupportedAlgorithm
		case walletKeyNotFound
		case secKeyNotFound
		case publicKeyError
		case walletSaveError
	}
	let kind: ErrorKind
	let message: String
}
