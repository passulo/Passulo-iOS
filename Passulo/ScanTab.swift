import CodeScanner
import CoreData
import Paseto
import SwiftUI

struct ScanTab: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var claims: PassuloClaims? = nil
    @State var verified: Bool? = nil
    @State var helpfulText: String = "Scanne einen QR Code mit der Kamera."

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true) { response in
                    switch response {
                    case .success(let result):
                        if let url = URL(string: result.string) {
                            checkUrl(url: url)
                        } else {
                            helpfulText = "Der Code enthält keine passende URL."
                        }
                    case .failure(let error):
                        helpfulText = "Es ist ein Problem aufgetreten: \(error.localizedDescription)"
                    }
                }
                .frame(maxHeight: 400)

                VStack {
                    if let claims = claims, let verified = verified {
                        NavigationLink {
                            MemberView(claims: claims, verified: verified)
                        } label: {
                            VStack {
                                VerifiedClaim(title: "Name", value: claims.fullname, verified: verified)
                                VerifiedClaim(title: "Mitgliedsnummer", value: claims.number, verified: verified)
                                VerifiedClaim(title: "Verband", value: claims.association, verified: verified)
                                VerifiedClaim(title: "Firma", value: claims.company, verified: verified)
                                VerifiedClaim(title: "Gültig bis", value: claims.validUntil.formatted, verified: verified)
                            }
                        }

                    } else {
                        Text(helpfulText)
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color(UIColor.quaternaryLabel), radius: 10)
                .padding()

                Spacer()
            }
            .navigationTitle("Passulo")
        }
        .onOpenURL { checkUrl(url: $0) }
    }

    private func checkUrl(url: URL) {
        claims = nil
        verified = nil

        if let claims = PasetoHelper().decode(url: url) {
            self.claims = claims
            verified = true
            addItem(url: url.absoluteString, claims: claims)
        }
    }

    private func addItem(url: String, claims: PassuloClaims) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.url = URL(string: url)
            newItem.name = claims.fullname
            newItem.association = claims.association
            newItem.number = claims.number

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
