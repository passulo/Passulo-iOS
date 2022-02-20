import SwiftUI

struct VerifiedClaim: View {
    let title: LocalizedStringKey
    let value: String?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value ?? "")
        }
    }
}
