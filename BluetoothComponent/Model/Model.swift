//
//  Model.swift
//  BluetoothComponent
//
//  Created by Jael Ruvalcaba on 02/04/21.
//

import Foundation

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
}
