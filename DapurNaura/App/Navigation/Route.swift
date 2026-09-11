//
//  Route.swift
//  DapurNaura
//
//  Created by Mohammad Azri Khairuddin on 06/08/26.
//

import Foundation

enum Route: Hashable {
    case classList(CookingClassListRoute)
    case classes(ClassRoute)
    case recipes(RecipeRoute)
    case offlineClasses(OfflineClassRoute)
    case payment(PaymentRoute)
}
