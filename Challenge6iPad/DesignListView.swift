import SwiftUI

//This is our main view list
struct ClothingDesignListView: View {
    @StateObject private var viewModel = DesignLibraryViewModel()
    @State private var showAddDesignView = false
    @State private var selectedDesignToEdit: ClothingDesign?
    
    //This will dynamically create grid columns based on screen width
    private var columns: [GridItem] {
        let deviceWidth = UIScreen.main.bounds.width
        let columnCount = deviceWidth > 1000 ? 2 : deviceWidth > 700 ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: columnCount)
    }
    
    var body: some View {
        VStack {
            // Custom navigation bar with the title and add button
            HStack {
                Text("Clothing Design Library")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showAddDesignView = true }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Grid of designs which is scrollable but we will change to sliding
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.designs) { design in
                        VStack {
                            // Display Design image
                            if let image = loadImage(imageName: design.imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 250)
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        selectedDesignToEdit = design
                                    }
                            }
                            
                            // Design info below the image name and category
                            VStack(alignment: .center) {
                                Text(design.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(design.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(10)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                }
                .padding()
            }
            
            // Show an emoty state if there are no designs
            if viewModel.designs.isEmpty {
                VStack {
                    Image(systemName: "cube.box")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    
                    Text("No Designs Yet")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Tap the '+' button to add your first design")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        //Show add design sheet
        .sheet(isPresented: $showAddDesignView) {
            AddDesignView()
                .environmentObject(viewModel)
        }
        //show edit design sheet
        .sheet(item: $selectedDesignToEdit) { design in
            EditDesignView(design: design)
                .environmentObject(viewModel)
        }
    }
    
    //Helper method that allows you to load the immage from photos
    func loadImage(imageName: String) -> UIImage? {
        guard let fileURL = getImageURL(for: imageName) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    private func getImageURL(for imageName: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
    }
}
