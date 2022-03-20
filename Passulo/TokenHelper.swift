import CryptoKit
import Foundation

struct ValidationResult {
    var signatureIsValid: Bool
    var keyBelongsToAssociation: Bool
    var passIsStillValid: Bool?
    func allValid() -> Bool {
        return signatureIsValid && keyBelongsToAssociation && passIsStillValid ?? false
    }
}

struct QrCodeContent {
    var url: URL
    var token: Token
    var tokenBytes: Data
    var signature: Data?
    var keyId: String?
}

enum TokenError: Error {
    case UnsupportedVersion
    case CannotReadToken
    case CannotDecode
}

enum ValidationError: Error {
    case NoSignatureOrKeyId
    case KeyNotFound(keyId: String)
}

enum TokenHelper {
    static func decode(url: URL) throws -> QrCodeContent {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           let code = queryItems.first(where: { $0.name == "code" })?.value,
           let tokenBytes = Data(base64urlEncoded: code)
        {
            if let token = try? Token(serializedData: tokenBytes) {
                let signature = queryItems.first(where: { $0.name == "sig" })?.value
                let decodedSig = signature.flatMap { sig in Data(base64urlEncoded: sig) }
                let keyid = queryItems.first(where: { $0.name == "kid" })?.value
                return QrCodeContent(url: url, token: token, tokenBytes: tokenBytes, signature: decodedSig, keyId: keyid)
            } else if let version = queryItems.first(where: { $0.name == "v" })?.value, version != "1"
            {
                throw TokenError.UnsupportedVersion

            } else {
                throw TokenError.CannotReadToken
            }
        } else {
            throw TokenError.CannotDecode
        }
    }

    static func validate(qrCodeContent: QrCodeContent, keyCache: KeyCache) async throws -> ValidationResult {
        if let signature = qrCodeContent.signature,
           let keyId = qrCodeContent.keyId
        {
            if let pkData = await keyCache.getInfoFor(server: qrCodeContent.url, keyId: keyId) {
                let pk = try! Curve25519.Signing.PublicKey(rawRepresentation: pkData.binaryKey)
                return ValidationResult(
                    signatureIsValid: pk.isValidSignature(signature, for: qrCodeContent.tokenBytes),
                    keyBelongsToAssociation: pkData.allowedAssociations.contains(qrCodeContent.token.association),
                    passIsStillValid: await KeyCache.shared.verifyPassId(server: qrCodeContent.url, passId: qrCodeContent.token.id))
            } else {
                throw ValidationError.KeyNotFound(keyId: keyId)
            }
        } else {
            throw ValidationError.NoSignatureOrKeyId
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
