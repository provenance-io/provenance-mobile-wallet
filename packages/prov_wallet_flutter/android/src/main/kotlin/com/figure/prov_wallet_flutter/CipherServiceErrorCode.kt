package com.figure.prov_wallet_flutter

/**
 * Must match values in Dart and Swift.
 */
@Suppress("unused")
enum class CipherServiceErrorCode {
    accessError,
    accountKeyNotFound,
    addSecItem,
    dataPersistence,
    invalidArgument,
    notAuthenticated,
    publicKeyError,
    secKeyNotFound,
    unknown,
    upgradeError,
    unsupportedAlgorithm,
}
