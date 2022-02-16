import Clibsodium
import Foundation
import Paseto
import Sodium

let sodium = Sodium()

struct PasetoMessage {
    let headerVersion: String
    let headerPurpose: String
    let payload: PasetoPayload
    let footer: [String: String]
    let rawFooter: String?
    let rawMessage: String
}

struct PasetoPayload {
    let messageBytes: Bytes
    let signatureBytes: Bytes
    let claims: [String: String]
}

enum PasetoHelper {
    static func decode(url: URL) -> PasetoMessage? {
        if let tokenString = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value,
           let message = decodePasetoMessage(string: tokenString)
        {
            print("Paseto Message: \(message)")
            return message
        } else {
            print("Could not extract Token from URL \(url)")
            return nil
        }
    }

    static func decodePasetoMessage(string: String) -> PasetoMessage? {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false).map(String.init)

        if let version = parts[safe: 0],
           let purpose = parts[safe: 1],
           let payload = decodePayload(string: parts[safe: 2]),
           let footer = decodeFooter(string: parts[safe: 3])
        {
            return PasetoMessage(headerVersion: version, headerPurpose: purpose, payload: payload, footer: footer, rawFooter: parts[safe: 3], rawMessage: string)
        } else {
            return nil
        }
    }

    static func decodePayload(string: String?) -> PasetoPayload? {
        let crypto_sign_ed25519_BYTES = Int(crypto_sign_bytes())

        if let string = string,
           let decoded = sodium.utils.base642bin(string, variant: .URLSAFE_NO_PADDING),
           decoded.count > crypto_sign_ed25519_BYTES
        {
            let signatureOffset = decoded.count - crypto_sign_ed25519_BYTES
            let message = decoded[..<signatureOffset].bytes

            if let claims = try? JSONSerialization.jsonObject(with: Data(bytes: message)) as? [String: String] {
                let signature = decoded[signatureOffset...].bytes
                return PasetoPayload(messageBytes: message, signatureBytes: signature, claims: claims)
            }
        }

        return nil
    }

    static func decodeFooter(string: String?) -> [String: String]? {
        if let string = string,
           let data = Data(base64Encoded: string),
           let footerClaims = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        {
            return footerClaims
        } else {
            return nil
        }
    }

    static func verifySignature(message: PasetoMessage) -> Bool {
        if let keyId = message.footer["kid"],
           let keys = knownKeys[keyId]
        {
            for key in keys {
                if let publicKey = try? Version2.AsymmetricPublicKey(hex: key),
                   verifyMessage(message: message, key: publicKey)
                {
                    print("Verification successful")
                    return true
                }
            }
            print("None of the known keys for KeyId \(keyId) were able to verify the message.")
            return false
        }
        print("No key found or keyId empty in footer: \(message.footer)")
        return false
    }

    static func verifyMessage(message: PasetoMessage, key: Version2.AsymmetricPublicKey) -> Bool {
        print("Trying to verify message with key")

        let header = "\(message.headerVersion).\(message.headerPurpose)." // v2.public.
        let headerBytes = Bytes(header.utf8)

        if let footerBytes = sodium.utils.base642bin(message.rawFooter ?? "", variant: .URLSAFE_NO_PADDING)
        {
            let messageBytes = UtilCopy.pae([headerBytes, message.payload.messageBytes, footerBytes])
            return sodium.sign.verify(
                message: messageBytes,
                publicKey: key.material,
                signature: message.payload.signatureBytes
            )
        } else {
            return false
        }
    }

    static let knownKeys = ["44424": ["26e1e471a072328b06980e4b25fa126e43da27f619e1e20212c0f0c0b46d37e2"]]
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public enum UtilCopy {
    static func pae(_ pieces: [Bytes]) -> Bytes {
        return pieces.reduce(le64(pieces.count)) {
            $0 + le64($1.bytes.count) + $1.bytes
        }
    }

    static func le64(_ n: Int) -> Bytes { return le64(UInt64(n)) }

    static func le64(_ n: UInt64) -> Bytes {
        // clear out the MSB
        let m = n & (UInt64.max >> 1)

        return (0 ..< 8).map { m >> (8 * $0) & 255 }.map(UInt8.init)
    }
}
