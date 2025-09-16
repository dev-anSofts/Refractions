//
//  Item.swift
//  Refractions
//
//  Created by Anthony Alessio Tralongo on 16/09/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
