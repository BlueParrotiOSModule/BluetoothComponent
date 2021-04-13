
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
    private var advertisementDataToSend = [CBAdvertisementDataServiceDataKey:"example",CBAdvertisementDataLocalNameKey:"Jael2522"]
    @Published var peripherals = [Peripheral]()
    @Published var isSwitchedOn = true
    @Published var AndroidMobileIsFound:Bool = false
    var centralManager:CBCentralManager!
    var peripherialManager:CBPeripheralManager!
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
        peripherialManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    //    MARK:= Own functions to make correct functionality
    
    func startScanningOrBroadCasting(){
        /* here we scan for the devices with a UUID that is specific to our app, which filters out other BLE devices.  */
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    func stopScanningOrStopBroadcasting(){
        centralManager.stopScan()
    }
}
//    MARK:= CoreBluetooth functions of the Peripherial that is once that send information
extension BLEManager: CBPeripheralManagerDelegate,CBPeripheralDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn{
        
            let data = CBMutableCharacteristic(type: hardCodeUUID, properties: [.read], value: userName.data(using: .utf8), permissions: [.readable])
         
              
            peripherialManager.startAdvertising(advertisementDataToSend)
            
            
            let serialService = CBMutableService(type: hardCodeUUID, primary: true)
            serialService.characteristics = [data]
            peripherialManager.add(serialService)
            
            
        }
        
    }
    
    //    MARK:= Function to receive data for a external device
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            if let value = request.value {
                
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                debugPrint("Zelda at %d", messageText)
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
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Periferico",peripheral)
    }
    
}

//    MARK:= CoreBluetooth functions of the Central that is once that receive information
extension BLEManager:CBCentralManagerDelegate{
    
    
    //    MARK:= Bluetooth State function
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state{
        case .unknown:
            isSwitchedOn = false
            
        case .resetting:
            isSwitchedOn = false
        
        case .unsupported:
            isSwitchedOn = false
        
        case .unauthorized:
            isSwitchedOn = false
        case .poweredOff:
            isSwitchedOn = false
        
        case .poweredOn:
            isSwitchedOn = true
            
        @unknown default:
            isSwitchedOn = false
            break;
        }
        
    }
   
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

            if  let name  = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                peripheralName = name
            }else{
                peripheralName = "Unknown name"
            }

           

            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue)

            print(newPeripheral)

            peripherals.append(newPeripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate  = self
        peripheral.discoverServices(nil)
    }
    
}
