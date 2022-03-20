import SwiftUI

struct MemberView: View {
    let url: URL

    @State var qrCodeContent: QrCodeContent?
    @State var errorMessage: String?
    @State var validationResult: ValidationResult?

    var body: some View {
        VStack {
            if let token = qrCodeContent?.token {
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

                        if let validationResult = validationResult {
                            if validationResult.allValid() {
                                Image(systemName: "checkmark.seal").foregroundColor(Color.green)
                            } else {
                                VStack(alignment: .trailing) {
                                    Image(systemName: "nosign").foregroundColor(Color.red)

                                    if validationResult.signatureIsValid == false {
                                        Text("Signature is not valid")
                                    }
                                    if validationResult.keyBelongsToAssociation == false {
                                        Text("The signing key is not allowed to create passes for this association.")
                                    }

                                    if validationResult.passIsStillValid == nil {
                                        Text("This pass is not known to the server.")
                                    }
                                    if validationResult.passIsStillValid == false {
                                        Text("This pass is not valid anymore.")
                                    }
                                }
                            }
                        } else {
                            ProgressView()
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
                Text("Unknown Error")
            }
        }
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
