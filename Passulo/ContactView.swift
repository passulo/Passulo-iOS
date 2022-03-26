//
//  ContactView.swift
//  Passulo
//
//  Created by Jannik Arndt on 26.03.22.
//

import Contacts
import ContactsUI
import SwiftUI

struct ContactView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    typealias UIViewControllerType = CNContactViewController
    var contact: CNContact

    func makeUIViewController(context: Context) -> CNContactViewController {
        let vc = CNContactViewController(forUnknownContact: contact)
        vc.contactStore = CNContactStore()
        vc.allowsActions = false
        vc.allowsEditing = false
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: CNContactViewController, context: Context) {}

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactView

        init(_ contactDetail: ContactView) {
            self.parent = contactDetail
        }

        func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
            return true
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            viewController.dismiss(animated: true)
        }
    }
}
