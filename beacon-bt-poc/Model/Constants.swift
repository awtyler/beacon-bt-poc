//
//  Constants.swift
//  beacon-bt-poc
//
//  Created by Aaron on 2/5/20.
//  Copyright © 2020 Rhindon Computing. All rights reserved.
//

import Foundation

struct Constants {
    
    static var UD_Peripheral_UUIDs = "beacon-bt-poc-discovered_peripherals"
    
    static var logger: Logger? {
        if MultiLogger.shared.loggerList.count == 0 {
            MultiLogger.shared.addLoggers(loggers: [
                "console": ConsoleLogger(),
                "web": WebLogger(logName: "beacon-bt-poc", url: URL(string: "https://logger.tylerinternet.com/Log")!)
            ], clearAll: true)
            return MultiLogger.shared
        }
        return MultiLogger.shared
    }
}
