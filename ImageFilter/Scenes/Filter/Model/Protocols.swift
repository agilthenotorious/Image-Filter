//
//  Delegates.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/4/20.
//

import Foundation

protocol ProviderDelegate: AnyObject {
    func updateProviders(provider: Provider, isOn: Bool)
}

protocol SwitchDelegate: AnyObject {
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool
}

protocol FilterDelegate: AnyObject {
    func updateFilters(with filter: ImageFilterType)
}
