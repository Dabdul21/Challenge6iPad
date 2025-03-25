import SwiftUI

struct AddDesignView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DesignLibraryViewModel
    
    @State private var designName = ""
    @State private var selectedCategory = ClothingDesign.Category.tShirt
    @State private var designImage: UIImage?
    @State private var showImagePicker = false
    
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
                
                // Save Button
                Section {
                    Button("Save Design") {
                        saveDesign()
                    }
                    .disabled(designName.isEmpty || designImage == nil)
                }
            }
            .navigationTitle("Add New Design")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $designImage)
            }
        }
    }
    
    private func saveDesign() {
        guard let image = designImage else { return }
        
        // Save image to app's documents directory
        let imageName = UUID().uuidString + ".jpg"
        if let data = image.jpegData(compressionQuality: 0.8) {
            let fileURL = getDocumentsDirectory().appendingPathComponent(imageName)
            try? data.write(to: fileURL)
            
            // Create and save design
            let newDesign = ClothingDesign(
                name: designName,
                category: selectedCategory,
                imageName: imageName
            )
            viewModel.addDesign(newDesign)
            
            // Dismiss view
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Helper method to get documents directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// Image Picker Wrapper for UIKit ImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
