//
//  ViewController.swift
//  iOSBlueParrotBluetooth
//
//  Created by Jose Rodriguez on 1/19/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var myPeripheral: CBPeripheral!
    var counter = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("BLE is powered on")
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Something is wrong with BLE")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let characteristicData = characteristic.value,
              let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
        
        print("Received %d bytes: %s", characteristicData.count, stringFromData)
    
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        var userName: String!
        
        
        
        print("Found device:" + String(peripheral.description) + ": " + String(counter))
//
        
        
        
        
        
        //We can check to see if the UUID is here. Perfect.
        if(advertisementData.description.contains("42B696BE-E823-11EA-ADC1-0242AC120002")) {
            
            print("HEEEERRREEEEE:")
            let dataMap = advertisementData[CBAdvertisementDataServiceDataKey]
//            let hashData = dataMap["42B696BE-E823-11EA-ADC1-0242AC120002"]
//            print(dataMap as? String)
            
//            let name: (key: String, value: NSObject) = advertisementData[CBAdvertisementDataServiceDataKey] as! (key: String, value: NSObject)
//
//            print(name.value)
        }
    
        
    
        
//        if let name = advertisementData[CBAdvertisementDataServiceDataKey] as? String {
//            userName = name
//            print("UserName: " + userName)
//        } else {
//            userName = "Unknown"
//
//        }

        counter += 1
    }

}

