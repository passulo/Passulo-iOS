//
//  ValidityField.swift
//  Passulo
//
//  Created by Jannik Arndt on 26.03.22.
//

import SwiftUI

struct ValidityField: View {
    @Binding var validationResult: ValidationResult?
    var body: some View {
        if let validationResult {
            if validationResult.allValid() {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.seal").foregroundColor(Color.green)
                        Text("Signatur ist gültig")
                    }
                    SignatureDetails(validationResult: validationResult)
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color.green, radius: 5)
                .padding(10)

            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "nosign").foregroundColor(Color.red)
                        Text("Signatur ist NICHT gültig")
                    }
                    SignatureDetails(validationResult: validationResult)
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                .shadow(color: Color.red, radius: 10)
                .padding(10)
            }
        } else {
            ProgressView()
        }
    }
}

struct SignatureDetails: View {
    let validationResult: ValidationResult

    var body: some View {
        if validationResult.signatureIsValid {
            Text("• Signatur stimmt mit Inhalt überein").font(.caption).foregroundColor(Color.green)
        } else {
            Text("• Signatur stimmt NICHT mit Inhalt überein").font(.caption).foregroundColor(Color.red)
        }

        if validationResult.keyBelongsToAssociation {
            Text("• Signatur stammt von \(validationResult.signingAssociation)").font(.caption).foregroundColor(Color.green)
            Text("• Überprüft von \(validationResult.signingServer)").font(.caption).foregroundColor(Color.green)

        } else {
            Text("• Signatur stammt NICHT von \(validationResult.signingAssociation)").font(.caption).foregroundColor(Color.red)
        }

        switch validationResult.passIsStillValid {
            case let .some(valid) where valid: Text("• Ausweis ist nicht wiederrufen").font(.caption).foregroundColor(Color.green)
            case .some: Text("• Ausweis ist wiederrufen").font(.caption).foregroundColor(Color.red)
            case .none: Text("• Ausweis ist unbekannt").font(.caption).foregroundColor(Color.red)
        }
    }
}
