import CryptoKit
import Foundation

struct PassuloResult {
    var token: Token?
    var valid: Bool
    var error: String? = nil
}

enum TokenHelper {
    static func decode(url: URL, keyCache: KeyCache) async -> PassuloResult {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
           let code = queryItems.first(where: { $0.name == "code" })?.value,
           let tokenBytes = Data(base64urlEncoded: code)
        {
            if let token = try? Token(serializedData: tokenBytes) {
                if let signature = queryItems.first(where: { $0.name == "sig" })?.value,
                   let decodedSig = Data(base64urlEncoded: signature),
                   let keyid = queryItems.first(where: { $0.name == "kid" })?.value
                {
                    if let pkData = await keyCache.getInfoFor(server: url, keyId: keyid) {
                        let pk = try! Curve25519.Signing.PublicKey(rawRepresentation: pkData.binaryKey)
                        let result = pk.isValidSignature(decodedSig, for: tokenBytes)
                        print("Validated with result: \(result)")

                        // todo allowed assocs

                        return PassuloResult(token: token, valid: result)
                    } else {
                        return PassuloResult(token: token, valid: false, error: "Could not find key for keyId '\(keyid)'")
                    }
                } else {
                    return PassuloResult(token: token, valid: false, error: "Could not find or decode signature")
                }
            } else if let version = queryItems.first(where: { $0.name == "v" })?.value,
                      version != "1"
            {
                return PassuloResult(token: nil, valid: false, error: "Unsupported version, result might be incomplete.")

            } else {
                return PassuloResult(token: nil, valid: false, error: "Could not read token.")
            }
        } else {
            print("url is \(url)")
            return PassuloResult(token: nil, valid: false, error: "Could not decode 'code'.")
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
