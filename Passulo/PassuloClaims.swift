import Foundation

struct PassuloClaims {
    let claims: [String: String]

    var firstname: String? { claims["fna"] }
    var middlename: String? { claims["mna"] }
    var lastname: String? { claims["lna"] }
    var gender: String? { claims["gnd"] }

    var fullname: String? {
        switch (pronoun(gender), firstname, middlename, lastname) {
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

    var association: String? { claims["asn"] }
    var number: String? { claims["num"] }
    var status: String? { claims["sts"] }
    var company: String? { claims["com"] }
    var email: String? { claims["eml"] }
    var telephone: String? { claims["tel"] }
    var validUntil: ValidityClaim { ValidityClaim(raw: claims["vut"]) }
}

struct ValidityClaim {
    let raw: String?

    var asDate: Date? {
        if let raw = raw {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: raw)
        } else { return nil }
    }

    var formatted: String? {
        if let date = asDate {
            let dateformat = DateFormatter()
            dateformat.locale = Locale.current
            dateformat.dateStyle = .medium // Nov 23, 1937
            dateformat.timeStyle = .none
            return dateformat.string(from: date)
        } else { return nil }
    }
}
