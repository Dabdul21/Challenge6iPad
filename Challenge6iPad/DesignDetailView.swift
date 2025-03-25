import SwiftUI

struct ClothingDesignDetailView: View {
    let design: ClothingDesign
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Design Image
                if let image = loadImage(imageName: design.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(15)
                        .shadow(radius: 10)
                }
                
                // Design Details
                Group {
                    //Displays designs name
                    Text(design.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    //Display Category and its value
                    HStack {
                        Text("Category:")
                            .fontWeight(.semibold)
                        Text(design.category.rawValue)
                    }
                    
                    //Displays the date commputed
                    HStack {
                        Text("Created:")
                            .fontWeight(.semibold)
                        Text(formattedDate)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Design Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //computed property which will return the creation date
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: design.createdAt)
    }
    
    //load an image from photos
    private func loadImage(imageName: String) -> UIImage? {
        //Looks for the files location if its successful it loads it from the path
        guard let fileURL = getImageURL(for: imageName) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    //Returns the full file path for given name
    private func getImageURL(for imageName: String) -> URL? {
        //Uses filemanager to locate documents directory on user device
        //Appends the imageName to get the full file URL
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
    }
}

//Displays a clothing design’s image and details
//Shows the design’s category and creation date
//Loads images from photos
//We add scrolling NEED TO CHANGE THIS TO SLIDE SCROLL
//

