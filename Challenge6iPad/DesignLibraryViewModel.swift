import Foundation
import SwiftUI

class DesignLibraryViewModel: ObservableObject {
    //Observable object allows SwiftUI views to reactively updae when the objects properties change
    //Automatically upadtes the UI when the deisgns change
    //Makes an observable property
    @Published var designs: [ClothingDesign] = [] //Designs changes, any SwiftUI views using it will automatically update
    
    // Save designs to UserDefaults (simple persistence)
    private let designsKey = "clothingDesigns"
    
    init() {
        loadDesigns()
    }
    
    // Add a new design
    func addDesign(_ design: ClothingDesign) {
        designs.append(design)
        saveDesigns()
    }
    
    // Remove a design
    func removeDesign(_ design: ClothingDesign) {
        designs.removeAll { $0.id == design.id }
        saveDesigns()
    }
    
    // Save designs to UserDefaults
    // Converts designs to JSON and stores them
    func saveDesigns() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(designs)
            UserDefaults.standard.set(encodedData, forKey: designsKey)
        } catch {
            print("Error saving designs: \(error)")
        }
    }
    
    // Load designs from UserDefaults
    //Retrieves and converts JSON back to designs
    private func loadDesigns() {
        guard let savedDesignsData = UserDefaults.standard.data(forKey: designsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            designs = try decoder.decode([ClothingDesign].self, from: savedDesignsData)
        } catch {
            print("Error loading designs: \(error)")
        }
    }
}
