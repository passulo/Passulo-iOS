import CodeScanner
import CoreData
import SwiftUI

struct ScanTab: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var token: Token? = nil
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
                    if let token = token, let verified = verified {
                        NavigationLink {
                            MemberView(token: token, verified: verified)
                        } label: {
                            VStack {
                                VerifiedClaim(title: "Name", value: token.fullname)
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
                                Text(helpfulText)
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
            .navigationViewStyle(.automatic)
        }
        .onOpenURL { checkUrl(url: $0) }
    }

    private func checkUrl(url: URL) {
        let message = TokenHelper.decode(url: url)
        token = message.token
        verified = message.valid
        helpfulText = message.error ?? ""
        if let token = token {
            addItem(url: url.absoluteString, token: token)
        }
    }

    private func addItem(url: String, token: Token) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.url = URL(string: url)
            newItem.name = token.fullname
            newItem.association = token.association
            newItem.number = token.number

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
