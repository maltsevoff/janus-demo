//
//  JanusTransaction.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 10.02.2022.
//

import Foundation

typealias TransactionSuccessBlock = ([String : Any]?) -> Void
typealias TransactionErrorBlock = ([String : Any]?) -> Void

class JanusTransaction: NSObject {
    
    let tid: String
    var success: TransactionSuccessBlock?
    var error: TransactionErrorBlock?
    
    // MARK: - Init
    
    init(tid: String) {
        self.tid = tid
    }
    
}
