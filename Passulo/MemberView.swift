import Contacts
import SwiftUI

struct MemberView: View {
    let url: URL

    @State var qrCodeContent: QrCodeContent?
    @State var errorMessage: String?
    @State var validationResult: ValidationResult?
    @State var contactInSheet: CNContact?

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    if let token = qrCodeContent?.token {
                        VStack(alignment: .leading, spacing: 30) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(token.fullname).font(.title)
                                Text(token.company).font(.title2)
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                if let url = URL(string: "mailto:\(token.email)") {
                                    Link(destination: url, label: { Text(token.email) })
                                }

                                if let url = token.phoneUrl {
                                    Link(destination: url, label: { Text(token.telephone) })
                                } else {
                                    Text(token.telephone)
                                }
                            }

                            if let number = token.number,
                               let association = token.association
                            {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Mitglied \(number)")
                                    Text(association)
                                }
                            }

                            if let validUntil = token.validUntil,
                               let validSince = token.memberSince
                            {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Mitglied seit \(validSince.formatted)")
                                    Text("Gültig bis \(validUntil.formatted)")
                                }
                            }

                            Button {
                                self.contactInSheet = token.toCNContact()
                            } label: {
                                Text("Kontakt speichern")
                            }

                            ValidityField(validationResult: $validationResult)
                        }
                        .padding(20)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color(UIColor.quaternaryLabel), radius: 10)
                        .padding(40)
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                    } else {
                        Text("Unknown Error")
                    }
                }
            }
        }
        .sheet(item: $contactInSheet, content: { contact in
            NavigationView {
                ContactView(contact: contact)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button { contactInSheet = nil } label: { Text("Fertig") }
                        }
                    }
            }

        })
        .onAppear {
            do {
                self.qrCodeContent = try TokenHelper.decode(url: url)
            } catch TokenError.UnsupportedVersion {
                self.errorMessage = "Unsupported version, result might be incomplete."
            } catch TokenError.CannotReadToken {
                self.errorMessage = "Could not read token."
            } catch TokenError.CannotDecode {
                self.errorMessage = "Could not decode 'code'."
            } catch {
                self.errorMessage = "An error occurred while reading the token."
            }
        }
        .task {
            if let qrCodeContent = qrCodeContent {
                do {
                    self.validationResult = try await TokenHelper.validate(qrCodeContent: qrCodeContent, keyCache: KeyCache.shared)
                } catch ValidationError.NoSignatureOrKeyId {
                    self.errorMessage = "The QR Code did not contain a signature or keyId."
                } catch let ValidationError.KeyNotFound(keyId: keyId) {
                    self.errorMessage = "The keyId \(keyId) could not be found on the server."
                } catch {
                    self.errorMessage = "An error occurred during validation."
                }
            }
        }
    }
}

extension CNContact: Identifiable {}
