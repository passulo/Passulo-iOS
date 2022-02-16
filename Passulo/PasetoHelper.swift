import Foundation
import Paseto

struct PasetoHelper {
    let publicHexKey = "26e1e471a072328b06980e4b25fa126e43da27f619e1e20212c0f0c0b46d37e2"

    func decode(url: URL) -> PassuloClaims? {
        if let tokenString = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value {
            return decode(string: tokenString)
        } else {
            print("Could not extract Token from URL \(url)")
            return nil
        }
    }

    func decode(string: String) -> PassuloClaims? {
        if let message = Message<Version2.Public>(string),
           let publicKey = try? Version2.AsymmetricPublicKey(hex: publicHexKey),
           let token = try? message.verify(with: publicKey)
        {
            return PassuloClaims(claims: token.claims)
        } else {
            return nil
        }
    }
}
