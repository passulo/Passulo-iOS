import SwiftUI

struct MemberView: View {
    let claims: PassuloClaims
    let verified: Bool

    init(claims: PassuloClaims, verified: Bool) {
        self.claims = claims
        self.verified = verified
    }

    init(item: Item) {
        if let url = item.url,
           let message = PasetoHelper.decode(url: url)
        {
            self.claims = PassuloClaims(claims: message.payload.claims)
            self.verified = PasetoHelper.verifySignature(message: message)
        } else {
            self.claims = PassuloClaims(claims: [:])
            self.verified = false
        }
    }

    var body: some View {
        VStack {
            VerifiedClaim(title: "Name", value: claims.fullname, verified: verified)
            VerifiedClaim(title: "Vorname", value: claims.firstname, verified: verified)
            VerifiedClaim(title: "Mittelname", value: claims.middlename, verified: verified)
            VerifiedClaim(title: "Nachname", value: claims.lastname, verified: verified)
            VerifiedClaim(title: "Gender", value: claims.gender, verified: verified)
            VerifiedClaim(title: "Mitgliedsnummer", value: claims.number, verified: verified)
            VerifiedClaim(title: "Verband", value: claims.association, verified: verified)
            VerifiedClaim(title: "Firma", value: claims.company, verified: verified)
            VerifiedClaim(title: "Gültig bis", value: claims.validUntil.formatted, verified: verified)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .shadow(color: Color(UIColor.quaternaryLabel), radius: 10)
        .padding()
    }
}
