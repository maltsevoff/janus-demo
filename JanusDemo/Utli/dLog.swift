//
//  dLog.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 11.02.2022.
//

import Foundation

public func dLog(_ object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
  #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("[\(className)] \(functionName) [#\(lineNumber)]| \(object)\n")
  #endif
}
