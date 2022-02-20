import CryptoKit
import Foundation

struct PassuloResult {
    var token: Token?
    var valid: Bool
    var error: String? = nil
}

enum TokenHelper {
    static func decode(url: URL) -> PassuloResult {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           let code = queryItems.first(where: { $0.name == "code" })?.value,
           let tokenBytes = Data(base64urlEncoded: code),
           let token = try? Token(serializedData: tokenBytes)
        {
            if let signature = queryItems.first(where: { $0.name == "sig" })?.value,
               let decodedSig = Data(base64urlEncoded: signature),
               let keyid = queryItems.first(where: { $0.name == "kid" })?.value
            {
                if let pkData = getPublicKey(for: keyid) {
                    let pk = try! Curve25519.Signing.PublicKey(rawRepresentation: pkData)
                    let result = pk.isValidSignature(decodedSig, for: tokenBytes)
                    print("Validated with result: \(result)")

                    return PassuloResult(token: token, valid: result)
                } else {
                    return PassuloResult(token: token, valid: false, error: "Could not find key for keyId")
                }
            } else {
                return PassuloResult(token: token, valid: false, error: "Could not find or decode signature")
            }

        } else {
            return PassuloResult(token: nil, valid: false, error: "Could not extract Token from URL")
        }
    }

    static func getPublicKey(for keyId: String) -> Data? {
        if keyId == "hhatworkv1" {
            let key = "MCowBQYDK2VwAyEAJuHkcaByMosGmA5LJfoSbkPaJ/YZ4eICEsDwwLRtN+I="
            // "26e1e471a072328b06980e4b25fa126e43da27f619e1e20212c0f0c0b46d37e2"
            let raw = String(key.dropFirst(16))
            let bin = Data(base64Encoded: raw)
            return bin
        } else {
            return nil
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
