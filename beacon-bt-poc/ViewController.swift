//
//  ViewController.swift
//
//  Created by Aaron on 11/5/19.
//  Copyright © 2019 Rhindon Computing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusText: UITextView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    
    var logger: Logger? = Constants.logger
    
    @Storage(key: Constants.UD_Peripheral_UUIDs, defaultValue: [])
    var peripheralIds: Set<UUID>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add a border to the status textView
        statusText!.layer.borderWidth = 1
        statusText!.layer.borderColor = UIColor.darkGray.cgColor
        
        let _ = BLEScanner.shared
        
        if !MultiLogger.shared.hasLogger(identifier: "vc") {
            MultiLogger.shared.addLogger(logger: self, identifier: "vc")
        }
        
        button1.setTitle("Scan for BLE", for: [])
        button2.setTitle("Stored BLE", for: [])
        button3.setTitle("Clear Stored BLE", for: [])
        button4.setTitle("Connect to BLE", for: [])
        button5.setTitle("Toggle Monitoring", for: [])
        button6.setTitle("Show Monitor Status", for: [])
        
        logger?.write("Ready")
        
        let deviceUuid = UIDevice.current.identifierForVendor
        logger?.write("Device ID for Vendor: \(deviceUuid?.uuidString.prefix(8) ?? "nil")")
    }
    
    func addToStatus(_ text: String) {
        DispatchQueue.main.async {
            var displayText = "[\(Date().stringWithFormat(format: "HH:mm:ss"))] \(text)"
            
            //Add newline characters to separate lines by an extra space
            if self.statusText.text.count > 0 {
                displayText = "\n\(displayText)"
            }
            self.statusText.text = "\(self.statusText.text ?? "")\(displayText)"
            
            //Scroll to bottom of the text
            if self.statusText.text.count > 0 {
                let location = self.statusText.text.count - 1
                let bottom = NSMakeRange(location, 1)
                self.statusText.scrollRangeToVisible(bottom)
            }
        }
    }
    
    @IBAction func clearLog(_ sender: Any) {
        self.statusText.text = ""
    }
    
    @IBAction func button1Action(_ sender: Any) {
        logger?.write("Scanning for 2s...")
        DispatchQueue.global(qos: .background).async {
            BLEScanner.shared.scanForDevices(forSeconds: 2) { (result) in
                switch result {
                case let .success(peripherals):
                    self.logger?.write("Found \(peripherals.count) devices.")
                    peripherals.forEach {
                        self.peripheralIds.insert($0.identifier)
                        self.logger?.write("   \($0.identifier.uuidString.prefix(8))")
                    }
                case let .failure(error):
                    self.logger?.write("Error scanning for devices: \(error)")
                }
            }
        }
    }
    
    @IBAction func button2Action(_ sender: Any) {
        if peripheralIds.count > 0 {
            logger?.write("Stored Devices:")
            peripheralIds.forEach {
                logger?.write("   \($0.uuidString.prefix(8))")
            }
        } else {
            logger?.write("No stored devices.")
        }
    }
    
    @IBAction func button3Action(_ sender: Any) {
        logger?.write("Clearing stored devices...")
        peripheralIds = []
        logger?.write("Done.")
    }
    
    @IBAction func button4Action(_ sender: Any) {
        logger?.write("Connecting to known peripherals for 2s...")
        BLEScanner.shared.connectToKnownPeripherals()
    }
    
    @IBAction func button5Action(_ sender: Any) {
        logger?.write("Button 5 pressed")
        
        if BeaconScanner.shared.isMonitoring {
            BeaconScanner.shared.stopMonitoring()
        } else {
            BeaconScanner.shared.startMonitoring()
        }
    }
    
    @IBAction func button6Action(_ sender: Any) {
        logger?.write("Button 6 pressed")
        BeaconScanner.shared.logStatus()
    }
    
    
}

extension ViewController: Logger {
    func write(_ text: String?, channel: String) {
        addToStatus("[\(channel)] \(text ?? "")")
    }
    
    func write(_ text: String?, datetime: Date) {
        addToStatus(text ?? "")
    }
    
    func write(_ text: String?, datetime: Date, channel: String) {
        addToStatus("[\(channel)] \(text ?? "")")
    }
    
    func write(_ text: String?) {
        addToStatus(text ?? "")
    }
}
