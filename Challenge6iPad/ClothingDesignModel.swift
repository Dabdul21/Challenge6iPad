import Foundation
import SwiftUI

// Clothing Design Model
struct ClothingDesign: Identifiable, Codable {
    let id: UUID //Unique ID for e/a design
    //allows using the design in SwiftUI lists and grids
    var name: String
    var category: Category
    var imageName: String
    var createdAt: Date //Keeps track of when the deisgn was created we can remove this
    
    // Enum for what type of product he is designing for
    enum Category: String, Codable, CaseIterable {
        case tShirt = "T-Shirt"
        case jacket = "Jacket"
        case dress = "Dress"
        case pants = "Pants"
        case sweater = "Sweater"
        case other = "Other"
    }
    
    // Initializer
    init(name: String, category: Category, imageName: String) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.imageName = imageName
        self.createdAt = Date()
    }
}
