//
//  Protocols.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/4/20.
//

import Foundation

protocol ProviderDelegate: class {
    func updateProviders(provider: Provider, isOn: Bool)
}

protocol SwitchDelegate: class {
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool
}
