//
//  Protocols.swift
//  ImageFilter
//
//  Created by Agil Madinali on 10/4/20.
//

import Foundation

protocol ProviderProtocol: AnyObject {
    func updateProviders(provider: Provider, isOn: Bool)
}

protocol SwitchProtocol: AnyObject {
    func updateSwitches(provider: Provider, isOn: Bool) -> Bool
}
