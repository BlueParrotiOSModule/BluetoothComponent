
//  BluetoothConnections.swift
//  BluetoothComponent
//  Created by Jael Ruvalcaba on 02/04/21.

import Foundation
import CoreBluetooth
import Combine

class BLEManager:NSObject,ObservableObject{
    
    let userName = "Jael1214"
    var hardCodeUUID = CBUUID(string: "42b696be-e823-11ea-adc1-0242ac120002")
    var peripheralName:String!
    @Published var peripherals = [Peripheral]()
    @Published var isSwitchedOn = false
    @Published var AndroidMobileIsFound:Bool = false
    var centralManager:CBCentralManager!
    var peripherialManager:CBPeripheralManager!
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        centralManager.delegate = self
        peripherialManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    //    MARK:= Own functions to make correct functionality
    
    func startScanningOrBroadCasting(){
        /* here we scan for the devices with a UUID that is specific to our app, which filters out other BLE devices.  */
        centralManager.scanForPeripherals(withServices: [hardCodeUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    func stopScanningOrStopBroadcasting(){
        centralManager.stopScan()
    }
}
//    MARK:= CoreBluetooth functions of the Peripherial that is once that send information
extension BLEManager: CBPeripheralManagerDelegate,CBPeripheralDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn{
            
            peripherialManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[hardCodeUUID],CBAdvertisementDataLocalNameKey:userName])
            
            let serialService = CBMutableService(type: hardCodeUUID, primary: true)
            let writeCharacteristics = CBMutableCharacteristic(type: hardCodeUUID,
                                                               properties: [.notify,.read,.write], value: nil,
                                                               permissions: [.writeable,.readable])
            serialService.characteristics = [writeCharacteristics]
            peripherialManager.add(serialService)
            
            
        }
        
    }
    
    //    MARK:= Function to receive data for a external device
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            if let value = request.value {
                
                //here is the message text that we receive, use it as you wish.
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
            }
            self.peripherialManager.respond(to: request, withResult: .success)
        }
    }
    
    //    MARK:= Find the correct cbuuid and match
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        guard error != nil else{return}
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                if service.uuid == hardCodeUUID {
                    debugPrint("We found the correct cbuuid")
                    AndroidMobileIsFound = true
                }else{
                    AndroidMobileIsFound = false
                    debugPrint("We  dont found the correct cbuuid")
                }
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error != nil else{ return}
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            let characteristicOfAndroidDevice = characteristic as CBCharacteristic
            if characteristicOfAndroidDevice.uuid.isEqual(hardCodeUUID){
                let dataToSend = userName.data(using: .utf8)
                peripheral.writeValue(dataToSend!, for: characteristicOfAndroidDevice, type: CBCharacteristicWriteType.withResponse)
            }else{
                print("Android UUID device not found")
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
}

//    MARK:= CoreBluetooth functions of the Central that is once that receive information
extension BLEManager:CBCentralManagerDelegate{
    
    
    //    MARK:= Bluetooth State function
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state{
        case .unknown:
            isSwitchedOn = false
            fallthrough
        case .resetting:
            isSwitchedOn = false
            fallthrough
        case .unsupported:
            isSwitchedOn = false
            fallthrough
        case .unauthorized:
            isSwitchedOn = false
            fallthrough
        case .poweredOff:
            isSwitchedOn = false
            fallthrough
        case .poweredOn:
            isSwitchedOn = true
            fallthrough
        @unknown default:
            isSwitchedOn = false
            break;
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Reject if the signal strength is too low to attempt data transfer.
        // Change the minimum RSSI value depending the case .
        guard RSSI.intValue >= -50 else{debugPrint("Discovered perhiperal not in expected range, at %d", RSSI.intValue);return}
        
        if AndroidMobileIsFound == false {
            guard let name  = advertisementData[CBAdvertisementDataLocalNameKey] as? String else{
                peripheralName = "Unknown name"
                return
            }
            
            peripheralName = name
            
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)
            
            print(newPeripheral)
            
            peripherals.append(newPeripheral)
        }else{
            stopScanningOrStopBroadcasting()
        }
        
        
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate  = self
        peripheral.discoverServices([hardCodeUUID])
    }
    
}
