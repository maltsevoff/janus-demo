//
//  String+Extension.swift
//  JanusDemo
//
//  Created by Aleksandr Maltsev on 09.02.2022.
//

import Foundation

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
