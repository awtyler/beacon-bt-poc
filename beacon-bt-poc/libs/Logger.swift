//
//  Logger.swift
//
//  Created by Aaron on 11/11/19.
//  Copyright © 2019 Rhindon Computing. All rights reserved.
//

import Foundation

protocol Logger {
    func write(_ text: String?)
    func write(_ text: String?, channel: String)
    func write(_ text: String?, datetime: Date)
    func write(_ text: String?, datetime: Date, channel: String)
}

class MultiLogger: Logger {

    static let shared = MultiLogger()

    var loggerList: [String: Logger] = [:]  //identifier:Logger

    var loggers: [Logger] { loggerList.keys.compactMap({ loggerList[$0] }) }
    
    private init() { }

    func addLogger(logger: Logger, clearAll: Bool = false, identifier: String?) {
        addLoggers(loggers: [identifier ?? "default": logger], clearAll: clearAll)
    }

    func addLoggers(loggers: [String: Logger], clearAll: Bool = false) {
        print("Adding Loggers.  clearAll: \(clearAll)")
        if clearAll {
            self.loggerList = loggers
        } else {
            for key in loggers.keys {
                self.loggerList[key] = loggers[key]!
            }
        }
    }
    
    func hasLogger(identifier: String) -> Bool {
        return loggerList.keys.contains(identifier)
    }

    func write(_ text: String?) {
        for logger in loggers {
            logger.write(text, datetime: Date())
        }
    }
    
    func write(_ text: String?, channel: String) {
        for logger in loggers {
            logger.write(text, datetime: Date(), channel: channel)
        }
    }
    
    func write(_ text: String?, datetime: Date = Date()) {
        for logger in loggers {
            logger.write(text, datetime: datetime)
        }
    }
    
    func write(_ text: String?, datetime: Date = Date(), channel: String) {
        for logger in loggers {
            logger.write(text, datetime: datetime, channel: channel)
        }
    }
}

class ConsoleLogger: Logger {

    func write(_ text: String?) {
        print(text ?? "")
    }

    func write(_ text: String?, channel: String) {
        print("\(channel): \(text ?? "")")
    }
    
    func write(_ text: String?, datetime: Date = Date()) {
        print("[\(datetime)]: \(text ?? "")")
    }
    
    func write(_ text: String?, datetime: Date = Date(), channel: String) {
        print("[\(datetime)] [\(channel)] \(text ?? "")")
    }

    
}

class WebLogger: Logger {

    struct LogEntry {
        let date: Date
        let text: String
        
        func toJsonString() -> String {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSS"
            let dateString = formatter.string(from: date)
            
            return """
            {
                "date": "\(dateString)",
                "text": "\(text.replacingOccurrences(of: "\"", with: "\\\""))"
            }
            """
        }
    }
    
    fileprivate let url: URL
    fileprivate let logName: String

    func write(_ text: String?) {
        write("\(text ?? "")", datetime: Date(), channel: "")
    }
    
    func write(_ text: String?, datetime: Date) {
        write("\(text ?? "")", datetime: datetime, channel: "")
    }
   
    func write(_ text: String?, channel: String) {
        write("\(text ?? "")", datetime: Date(), channel: channel)
    }

    func write(_ text: String?, datetime: Date = Date(), channel: String) {
        
        let postLogName = "\(logName)\(channel != "" ? "-\(channel)" : "")"
        let url = URL(string: "\(self.url.absoluteString)/\(postLogName)")
        
        let entry = LogEntry(date: datetime, text: text ?? "")
        let payload = entry.toJsonString()
        
        url?.postAndForget(withBody: payload)
    }

    init(logName: String? = nil, url: URL) {
        self.logName = logName ?? "default"
        self.url = url
    }
}
