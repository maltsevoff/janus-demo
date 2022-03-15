//
//  Dictionary+Extension.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 10.02.2022.
//

import Foundation

extension Dictionary {
    
    func toJsonString() -> String {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data, encoding: String.Encoding.utf8)
            return convertedString ?? ""
        } catch {
            return ""
        }
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
