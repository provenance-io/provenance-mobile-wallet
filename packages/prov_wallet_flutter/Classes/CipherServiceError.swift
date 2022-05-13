import Foundation

struct CipherServiceError: Error {
    ///
    /// Must match values in Dart and Kotlin.
    ///
    enum CipherServiceErrorCode {
        case accessError
        case accountKeyNotFound
        case addSecItem
        case dataPersistence
        case invalidArgument
        case publicKeyError
        case secKeyNotFound
        case unknown
        case upgradeError
        case unsupportedAlgorithm
    }

    let kind: CipherServiceErrorCode
    let message: String
}
