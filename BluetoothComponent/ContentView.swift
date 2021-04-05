//
//  ContentView.swift
//  BluetoothComponent
//  Created by Jael Ruvalcaba on 02/04/21.

import SwiftUI

struct ContentView: View {

@ObservedObject var bleManager =  BLEManager()
    
    var body: some View {
        VStack (spacing: 10) {

            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            List() {
                Text("placeholder 1")
                Text("placeholder 2")
            }.frame(height: 300)

            Spacer()
        
            
            Text("STATUS")
                .font(.headline)

            // Status goes here
           
            if bleManager.isSwitchedOn  {
                Text("Bluetooth is switched on")
                    .foregroundColor(.green)
            }
            else {
                Text("Bluetooth is NOT switched on")
                    .foregroundColor(.red)
            }

            Spacer()

            HStack {
                VStack (spacing: 10) {
                    Button(action: {
                        debugPrint("Start Scanning")
                        self.bleManager.startScanningOrBroadCasting()
                    }) {
                        Text("Start Scanning")
                    }
                    Button(action: {
                        
                            debugPrint("Stop Scanning")
                        self.bleManager.stopScanningOrStopBroadcasting()
                    }) {
                        Text("Stop Scanning")
                    }
                }.padding()

                Spacer()

                VStack (spacing: 10) {
                    Button(action: {
                        print("Start Advertising")
                    }) {
                        Text("Start Advertising")
                    }
                    Button(action: {
                        print("Stop Advertising")
                    }) {
                        Text("Stop Advertising")
                    }
                }.padding()
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
