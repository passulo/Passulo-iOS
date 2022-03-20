//
//  URL.swift
//  Passulo
//
//  Created by Jannik Arndt on 20.03.22.
//

import Foundation

extension URL {
    func schemeAndHost() -> URL {
        let comp = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var newUrl = URLComponents()

        newUrl.host = comp?.host
        newUrl.scheme = comp?.scheme

        return newUrl.url!
    }
}
