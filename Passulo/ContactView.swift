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
        Coordinator(self)
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

    func updateUIViewController(_: CNContactViewController, context _: Context) {}

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactView

        init(_ contactDetail: ContactView) {
            parent = contactDetail
        }

        func contactViewController(_: CNContactViewController, shouldPerformDefaultActionFor _: CNContactProperty) -> Bool {
            true
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith _: CNContact?) {
            viewController.dismiss(animated: true)
        }
    }
}
