import SwiftUI

struct EditDesignView: View {
    @EnvironmentObject var viewModel: DesignLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let design: ClothingDesign
    @State private var designName: String
    @State private var selectedCategory: ClothingDesign.Category
    @State private var designImage: UIImage?
    @State private var showImagePicker = false
    
    func loadImage(imageName: String) -> UIImage? {
        guard let fileURL = getImageURL(for: imageName) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    
    init(design: ClothingDesign) {
        self.design = design
        _designName = State(initialValue: design.name)
        _selectedCategory = State(initialValue: design.category)
        _designImage = State(initialValue: loadImage(imageName: design.imageName))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Design Name Section
                Section(header: Text("Design Details")) {
                    TextField("Design Name", text: $designName)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ClothingDesign.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                // Image Selection Section
                Section(header: Text("Design Image")) {
                    if let image = designImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Text(designImage == nil ? "Select Image" : "Change Image")
                    }
                }
                
                // Delete Design Button
                Section {
                    Button("Delete Design", role: .destructive) {
                        deleteDesign()
                    }
                }
            }
            .navigationTitle("Edit Design")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveDesign()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $designImage)
            }
        }
    }
    
    private func saveDesign() {
        // Remove old image if a new one is selected
        if let newImage = designImage {
            // Delete old image
            if let oldFileURL = getImageURL(for: design.imageName) {
                try? FileManager.default.removeItem(at: oldFileURL)
            }
            
            // Save new image
            let imageName = UUID().uuidString + ".jpg"
            if let data = newImage.jpegData(compressionQuality: 0.8) {
                let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
                try? data.write(to: fileURL)
                
                // Update design in view model
                if var index = viewModel.designs.firstIndex(where: { $0.id == design.id }) {
                    viewModel.designs[index].name = designName
                    viewModel.designs[index].category = selectedCategory
                    viewModel.designs[index].imageName = imageName
                    viewModel.saveDesigns()
                }
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteDesign() {
        // Remove image file
        if let fileURL = getImageURL(for: design.imageName) {
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Remove from view model
        viewModel.removeDesign(design)
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // Helper methods
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func getImageURL(for imageName: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
    }
    
    // Static method to load image (since it can't be an instance method in this context)
    private static func loadImage(imageName: String) -> UIImage? {
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
}
