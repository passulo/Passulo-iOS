import CodeScanner
import CoreData
import SwiftUI

struct ScanTab: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State var qrCodeContent: QrCodeContent?
    @State var validationResult: ValidationResult?
    @State var helpfulText: String = "Scanne einen QR Code mit der Kamera."

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true) { response in
                    switch response {
                        case let .success(result):
                            if let url = URL(string: result.string) {
                                checkUrl(url: url)
                            } else {
                                helpfulText = "Der Code enthält keine passende URL."
                            }
                        case let .failure(error):
                            helpfulText = "Es ist ein Problem aufgetreten: \(error.localizedDescription)"
                    }
                }
                .frame(maxHeight: 400)

                VStack {
                    if let qrCodeContent {
                        NavigationLink {
                            MemberView(url: qrCodeContent.url)
                        } label: {
                            VStack {
                                VerifiedClaim(title: "Name", value: qrCodeContent.token.fullname)
                                VerifiedClaim(title: "Mitgliedsnummer", value: qrCodeContent.token.number)
                                VerifiedClaim(title: "Verband", value: qrCodeContent.token.association)
                                VerifiedClaim(title: "Firma", value: qrCodeContent.token.company)
                                VerifiedClaim(title: "Gültig bis", value: qrCodeContent.token.validUntil.formatted)
                                HStack {
                                    Text("Validiert")
                                    Spacer()
                                    if let validationResult {
                                        if validationResult.allValid() {
                                            Image(systemName: "checkmark.seal").foregroundColor(Color.green)
                                        } else {
                                            Image(systemName: "nosign").foregroundColor(Color.red)
                                        }
                                    } else {
                                        ProgressView()
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
        do {
            qrCodeContent = try TokenHelper.decode(url: url)
            if let qrCodeContent {
                helpfulText = ""
                addItem(url: url.absoluteString, token: qrCodeContent.token)

                Task {
                    do {
                        validationResult = try await TokenHelper.validate(qrCodeContent: qrCodeContent, keyCache: KeyCache.shared)
                    } catch ValidationError.NoSignatureOrKeyId {
                        helpfulText = "The QR Code did not contain a signature or keyId."
                    } catch let ValidationError.KeyNotFound(keyId: keyId) {
                        helpfulText = "The keyId \(keyId) could not be found on the server."
                    } catch {
                        helpfulText = "An error occurred during validation."
                    }
                }
            }
        } catch TokenError.UnsupportedVersion {
            helpfulText = "Unsupported version, result might be incomplete."
        } catch TokenError.CannotReadToken {
            helpfulText = "Could not read token."
        } catch TokenError.CannotDecode {
            helpfulText = "Could not decode 'code'."
        } catch {
            helpfulText = "An error occurred while reading the token."
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
