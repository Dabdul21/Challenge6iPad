import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

//This bridges SwiftUI and RealityKit by using UIViewRepresentable to embed an ARView inSwiftU
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
       //ARView is the RealityKit scene where we place AR objects
        
        // Ensure AR body tracking is supported on the device
        guard ARBodyTrackingConfiguration.isSupported else {
            print("Body tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARBodyTrackingConfiguration() //ARBodyTrackingConfiguration enables full-body tracking
        arView.session.run(configuration) //starts the Ar tracking
        
        // Create a body anchor and add it to the scene
        let anchorEntity = AnchorEntity(.body) //body attaches obj to human body
        arView.scene.addAnchor(anchorEntity)
        
        // Create a sphere to place on top of the right hand
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        let sphereMaterial = SimpleMaterial(color: .red, roughness: 0.15, isMetallic: true)
        
        let model = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
        anchorEntity.addChild(model)
        
        context.coordinator.anchorEntity = anchorEntity // is assigned the body anchor reference
        arView.session.delegate = context.coordinator //allows tracking updates
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    //Creates a Coordinator instance to handle body trackin
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var anchorEntity: AnchorEntity? //This class listens for AR tracking updates.

        //Update Sphere Position on Body Movement
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            //Loop through detected AR anchors
            for anchor in anchors {
                //heck if the anchor is a body anchor
                if let bodyAnchor = anchor as? ARBodyAnchor {
                    if let rightHandTransform = bodyAnchor.skeleton.modelTransform(for: .rightHand) {
                        let transformMatrix = simd_float4x4(rightHandTransform)
                        //Find the sphere and update its position to match the right hand
                        
                        // Ensure we update the position of the first child (our sphere)
                        if let sphereEntity = anchorEntity?.children.first as? ModelEntity {
                            sphereEntity.transform.matrix = transformMatrix
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

