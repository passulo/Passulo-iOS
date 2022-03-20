import SwiftUI

struct MemberView: View {
    let url: URL?

    @State var token: Token?
    @State var verified: Bool?
    @State var errorMessage: String?

    var body: some View {
        VStack {
            if let token = token {
                VStack {
                    VerifiedClaim(title: "Name", value: token.fullname)
                    VerifiedClaim(title: "Vorname", value: token.firstName)
                    VerifiedClaim(title: "Mittelname", value: token.middleName)
                    VerifiedClaim(title: "Nachname", value: token.lastName)
                    VerifiedClaim(title: "Gender", value: token.gender)
                    VerifiedClaim(title: "Mitgliedsnummer", value: token.number)
                    VerifiedClaim(title: "Verband", value: token.association)
                    VerifiedClaim(title: "Firma", value: token.company)
                    VerifiedClaim(title: "Gültig bis", value: token.validUntil.formatted)
                    HStack {
                        Text("Validiert")
                        Spacer()
                        if verified == true {
                            Image(systemName: "checkmark.seal").foregroundColor(Color.green)
                        } else {
                            Image(systemName: "nosign").foregroundColor(Color.red)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color(UIColor.quaternaryLabel), radius: 10)
                .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
            } else {
                ProgressView("Loading")
            }
        }
        .task {
            if let url = url {
                let result = await TokenHelper.decode(url: url, keyCache: KeyCache.shared)
                self.token = result.token
                self.verified = result.valid
                self.errorMessage = result.error
            } else {
                self.errorMessage = "No valid URL given"
            }
        }
    }
}
