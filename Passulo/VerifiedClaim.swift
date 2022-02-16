import SwiftUI

struct VerifiedClaim: View {
    let title: LocalizedStringKey
    let value: String?
    let verified: Bool?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value ?? "")
            if verified == true {
                Image(systemName: "checkmark.seal").foregroundColor(Color.green)
            } else {
                Image(systemName: "nosign").foregroundColor(Color.red)
            }
        }
    }
}
