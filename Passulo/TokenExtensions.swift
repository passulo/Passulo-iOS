import Foundation
import SwiftProtobuf

typealias Token = Com_Passulo_V1_Token

extension String {
    func nilIfEmpty() -> String? {
        if isEmpty {
            return nil
        } else {
            return self
        }
    }
}

extension Token {
    var fullname: String {
        switch (pronoun(gender.nilIfEmpty()), firstName.nilIfEmpty(), middleName.nilIfEmpty(), lastName.nilIfEmpty()) {
        case (_, .some(let f), .some(let m), .some(let l)): return "\(f) \(m) \(l)"
        case (_, .some(let f), .none, .some(let l)): return "\(f) \(l)"
        case (.some(let g), .none, .none, .some(let l)): return "\(g) \(l)"
        case (.none, .none, .none, .some(let l)): return "\(l)"
        default: return "<no name>"
        }
    }

    func pronoun(_ gender: String?) -> String? {
        switch gender {
        case .some("m"): return NSLocalizedString("Mr.", comment: "honorific for male")
        case .some("f"): return NSLocalizedString("Ms.", comment: "honorific for female")
        case .some("d"): return NSLocalizedString("Mx.", comment: "honorific for neutral")
        default: return nil
        }
    }

    var phoneUrl: URL? {
        var telUrl = URLComponents()
        telUrl.scheme = "tel"
        telUrl.path = telephone
        return telUrl.url
    }
}

extension Google_Protobuf_Timestamp {
    var formatted: String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale.current
        dateformat.dateStyle = .medium // Nov 23, 1937
        dateformat.timeStyle = .none
        return dateformat.string(from: date)
    }
}
