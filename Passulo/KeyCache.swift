//
//  KeyCache.swift
//  Passulo
//
//  Created by Jannik Arndt on 05.03.22.
//

import Foundation

typealias ServerKeys = [Key]

class KeyCache: ObservableObject {
    static let shared = KeyCache()

    var keys: [URL: ServerKeys] = [:]

    func getInfoFor(server: URL, keyId: String) async -> Key? {
        let serverUrl = server.schemeAndHost()

        print("Getting info for keyId \(keyId) on Server \(serverUrl)…")
        if let serverKeys = keys[serverUrl] {
            if let key = serverKeys.first(where: { $0.keyID == keyId }) {
                print("Found key in cache: \(key)")
                return key
            } else {
                print("Key not found on server \(serverUrl)")
                return nil
            }
        } else {
            print("Asking server…")
            await loadKeys(for: serverUrl)
            return await getInfoFor(server: serverUrl, keyId: keyId)
        }
    }

    func loadKeys(for server: URL) async {
        do {
            var components = URLComponents()
            components.scheme = server.scheme
            components.host = server.host
            components.path = "/v1/keys"
            let url = components.url!
            print("Request to \(url)")

            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: TimeInterval(11))
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)

            let httpResponse = response as! HTTPURLResponse

            switch httpResponse.statusCode {
            case 200:
                let responseData: ServerKeys = try JSONDecoder().decode(ServerKeys.self, from: data)
                keys[server] = responseData

            default:
                print("Error in HTTP request: \(httpResponse)")
            }

        } catch {
            print("Error in HTTP request: \(error)")
        }
    }
}

struct Key: Codable {
    let keyID, publicKey: String
    let allowedAssociations: [String]

    enum CodingKeys: String, CodingKey {
        case keyID = "keyId"
        case publicKey, allowedAssociations
    }

    var binaryKey: Data {
        let raw = String(publicKey.dropFirst(16))
        return Data(base64Encoded: raw)!
    }
}
