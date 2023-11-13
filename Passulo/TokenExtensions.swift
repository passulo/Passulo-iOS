import Contacts
import Foundation
import SwiftProtobuf

typealias Token = Com_Passulo_V1_Token

extension String {
    func nilIfEmpty() -> String? { if isEmpty { nil } else { self } }
}

extension Token {
    var fullname: String {
        switch (pronoun(gender), firstName.nilIfEmpty(), middleName.nilIfEmpty(), lastName.nilIfEmpty()) {
            case let (_, .some(f), .some(m), .some(l)): "\(f) \(m) \(l)"
            case let (_, .some(f), .none, .some(l)): "\(f) \(l)"
            case let (.some(g), .none, .none, .some(l)): "\(g) \(l)"
            case let (.none, .none, .none, .some(l)): "\(l)"
            default: "<no name>"
        }
    }

    func pronoun(_ gender: Com_Passulo_V1_Token.Gender) -> String? {
        switch gender {
            case .female:
                NSLocalizedString("Ms.", comment: "honorific for female")
            case .male:
                NSLocalizedString("Mr.", comment: "honorific for male")
            case .diverse:
                NSLocalizedString("Mx.", comment: "honorific for neutral")

            default: nil
        }
    }

    var phoneUrl: URL? {
        var telUrl = URLComponents()
        telUrl.scheme = "tel"
        telUrl.path = telephone
        return telUrl.url
    }

    func toCNContact() -> CNContact {
        let contact = CNMutableContact()
        contact.contactType = CNContactType.person
        contact.givenName = firstName
        contact.middleName = middleName
        contact.familyName = lastName
        contact.emailAddresses.append(CNLabeledValue(label: CNLabelWork, value: email as NSString))
        contact.phoneNumbers.append(CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: telephone)))
        contact.organizationName = company
        contact.note = association

        return contact
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
