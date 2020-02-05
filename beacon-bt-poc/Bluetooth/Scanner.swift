//
//  Scanner.swift
//  beacon-bt-poc
//
//  Created by Aaron on 2/5/20.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation
import CoreBluetooth

enum ScannerError: Error {
    case NotConnectedError
    case PeripheralNotFoundError
    case UnableToConnectToPeripheralError
    
    var localizedDescription: String {
        switch self {
        case .NotConnectedError: return "NotConnectedError"
        case .PeripheralNotFoundError: return "PeripheralNotFoundError"
        case .UnableToConnectToPeripheralError: return "UnableToConnectToPeripheralError"
        }
    }
}

class Scanner: NSObject {
    
    static var shared: Scanner = Scanner()
    
    private var centralManager: CBCentralManager!
    private var logger = Constants.logger
    private var serviceId = CBUUID(string: "00001523-1212-EFDE-1523-785FEABCD123")
    
    @Storage(key: Constants.UD_Peripheral_UUIDs, defaultValue: [])
    var peripheralIds: Set<UUID>
    
    fileprivate var foundDevices: [CBPeripheral] = []   //NOTE: only holds devices while scanning. Expected to be empty when not scanning for devices.
    
    override private init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }

    func scanForDevices(forSeconds seconds: TimeInterval, completion: @escaping (Result<[CBPeripheral], ScannerError>) -> Void) {
        
        guard centralManager.state == .poweredOn else {
            completion(.failure(.NotConnectedError))
            return
        }

        DispatchQueue.global(qos: .background).async {
            self.foundDevices = []
            self.centralManager.scanForPeripherals(withServices: [self.serviceId], options: nil)
        }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + seconds) {
            self.centralManager.stopScan()
            completion(.success(self.foundDevices))
        }
        
    }
    
    func connectToKnownPeripherals() {
        
        peripheralIds.forEach { uuid in
            connectToPeripheral(withUuid: uuid) { (result) in
                switch result {
                case let .failure(error):
                    self.logger?.write("Error connecting to peripheral \(uuid.uuidString.prefix(8)): \(error)")
                case .success:
                    self.logger?.write("Done connecting to peripheral: \(uuid.uuidString.prefix(8))")
                }
            }
        }
        
    }
    
    func connectToPeripheral(withUuid uuid: UUID, completion: @escaping (Result<Void, ScannerError>) -> Void) {

        guard centralManager.state == .poweredOn else {
            completion(.failure(.NotConnectedError))
            return
        }

        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
            completion(.failure(.PeripheralNotFoundError))
            return
        }

        centralManager.connect(peripheral)

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            if peripheral.state == .connected {
                self.centralManager.cancelPeripheralConnection(peripheral)
                completion(.success(()))
            } else {
                self.centralManager.cancelPeripheralConnection(peripheral)
                completion(.failure(.UnableToConnectToPeripheralError))
            }
        }
        
    }
}


extension Scanner: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        foundDevices.append(peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            logger?.write("Bluetooth is On")
        } else {
            logger?.write("Bluetooth is not active")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger?.write("Connected to peripheral: \(peripheral.identifier.uuidString.prefix(8))")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger?.write("Failed to connect to peripheral: \(peripheral.identifier.uuidString.prefix(8))")
    }
}
