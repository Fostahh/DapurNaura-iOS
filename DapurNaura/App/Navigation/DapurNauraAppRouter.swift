//
//  DapurNauraAppRouter.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import Foundation

@MainActor
@Observable
final class DapurNauraAppRouter {
    var root: RootRoute = .auth

    var path: [Route] = []
}
