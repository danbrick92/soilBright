//
//  bluetooth.swift
//  SoilBright
//
//  Created by Dan Brickner on 6/22/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

let serviceCBUUID = CBUUID(string: "0xFFE0") // the service id
let characteristicCBUUID = CBUUID(string: "FFE1") // the characteristic id
private var writeType: CBCharacteristicWriteType = .withoutResponse // default write type
private var writeCharacteristic: CBCharacteristic?
private var perph:CBPeripheral? // the periphral connected to

class Shared: NSObject {
    
    var centralManager: CBCentralManager! // Manages bluetooth
    var thePeripheral: CBPeripheral! // store the periphral
    var updateLabel: (() -> Void)?
    var connectionEstablished: (() -> Void)?
    public var dataReceived : String {
        didSet {
            updateLabel?()
        }
    } // stores data received
    public var weight : String
    public var moisture : String
    static let instance = Shared()
    public var simulation = false
    
    var secondController = false
    var calController = false
    var weightController = false
    var moistureController = false
    var hasConnected = false
    
    override init(){
        self.dataReceived = "null"
        self.weight = "null"
        self.moisture = "null"
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil) // init bluetooth mgr
    }
    
    func sendData(_ data: String) {
        sendMessageToDevice(data)
    }
    
    func onDataReceived(_ data: String) {
        self.dataReceived = String(data)
        print("Data Received: \(data)")
    }
    
    func checkExpectedMode(className: String) -> String{
        var retval = ""
        // Check if this class looked at
        var modeState = false
        if (className == "second"){
            modeState = secondController
        }
        else if (className == "calibrate"){
            modeState = calController
        }
        else if (className == "weight"){
            modeState = weightController
        }
        else if (className == "moisture"){
            modeState = moistureController
        }
        
        
        //modeState = false
        // If it has, need to check state of microcontroller
        if (modeState) {
            retval = "start"
            // Bluetooth is on
            if (centralManager.state == .poweredOn) {
                // actively connected to bluetooth device
                let periphrals = centralManager.retrieveConnectedPeripherals(withServices: [serviceCBUUID])
                if (periphrals.count > 0){
                    retval = "second"
                }
            }
            dataReceived = "null"
            weight = "null"
            moisture = "null"
            if (simulation) {
                modeState = false
                retval = ""
            }
            else{
                secondController = true
                moistureController = false
                calController = false
                weightController = false
            }
            // reset variables back
            
            
        }
        
        return retval
    }
}

extension Shared: CBCentralManagerDelegate { // delegates methods by manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      switch central.state {

          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [serviceCBUUID]) // after on, then scan periphral
        }
    }
    
    // scans and connects to bluetooth
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      print(peripheral)
      thePeripheral = peripheral
      thePeripheral.delegate = self
      perph = thePeripheral
      centralManager.stopScan()
      centralManager.connect(thePeripheral)
      hasConnected = true
    }

    // once connected, discovers services
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("Connected!")
      thePeripheral.discoverServices(nil)
    }
    
    /// Send a string to the device
    func sendMessageToDevice(_ message: String) {
        print(message)
        if let data = message.data(using: String.Encoding.utf8) {
            perph!.writeValue(data, for: writeCharacteristic!, type: writeType)
        }
    }
}



// discovers services
extension Shared: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }

    for service in services {
      print(service)
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                  error: Error?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      print(characteristic)
      if characteristic.properties.contains(.read) {
        print("\(characteristic.uuid): properties contains .read")
      }
      if characteristic.properties.contains(.notify) {
        print("\(characteristic.uuid): properties contains .notify")
        peripheral.setNotifyValue(true, for: characteristic)
      }
      writeCharacteristic = characteristic
      writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
      
      peripheral.readValue(for: characteristic)
    }
    connectionEstablished!()
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                  error: Error?) {
    switch characteristic.uuid {
      case characteristicCBUUID:
        let data_received = dataLocation(from: characteristic)
        if data_received != "" {self.dataReceived = data_received}
        
        //print(characteristic.value ?? "no value")
        
      default:
        print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }
    
    private func dataLocation(from characteristic: CBCharacteristic) -> String {
      let data = characteristic.value
      guard data != nil else { return "" }
      var retval = ""
      if let str = String(data: data!, encoding: String.Encoding.utf8) {
          retval = str
          print(retval)
      } else {
        retval = ""
        print("Received an invalid string!") //uncomment for debugging
      }
      return  retval
      
    }

}

