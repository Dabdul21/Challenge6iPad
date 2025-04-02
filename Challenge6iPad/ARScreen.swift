import SwiftUI
import ARKit
import SceneKit
import PhotosUI
import Vision

// Main SwiftUI view that hosts our AR experience
struct ARScreen: View {
    var body: some View {
        // Use UIViewRepresentable to wrap UIKit AR view in SwiftUI
        ARCameraViewRepresentable()
            .edgesIgnoringSafeArea(.all)  // Make AR view full screen
    }
}

// This struct bridges between SwiftUI and UIKit
struct ARCameraViewRepresentable: UIViewControllerRepresentable {
    // Create the AR view controller
    func makeUIViewController(context: Context) -> ARCameraViewController {
        return ARCameraViewController()
    }
    
    // Update the controller if needed
    func updateUIViewController(_ uiViewController: ARCameraViewController, context: Context) {
        // Updates handled by the view controller itself
    }
}

// Main AR View Controller class that manages the AR experience
class ARCameraViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var userHasMovedImage = false

    // Main AR view that displays camera feed and 3D content
    var arView: ARSCNView!
    
    // The image that user uploads to apply to the model
    var uploadedImage: UIImage?
    
    // Reference to the 3D model node in the scene
    var modelNode: SCNNode?
    
    // Body skeleton node for tracking
    var skeletonNode: SCNNode?
    
    // Material with environmental reflection properties
    var environmentMaterial: SCNMaterial?
    
    // Properties for gesture handling
    var initialScale: CGFloat = 1.0
    var currentRotation: Float = 0.0
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Special handling for Xcode preview mode
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            setupPreviewMode()
            return
        }
        #endif
        
        // Setup the actual AR experience
        setupARView()
        setupUI()
        setupGestureRecognizers()
        setupEnvironmentMapping()
        addInteractiveElements()
        loadAndPlaceModel()
        setupBodyTracking()
    }
    
    // Setup a preview mode for SwiftUI Canvas preview
    private func setupPreviewMode() {
        // Create a simpler view for preview that doesn't require AR
        view.backgroundColor = .black
        
        // Add back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("<back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.frame = CGRect(x: 20, y: 40, width: 80, height: 30)
        view.addSubview(backButton)
        
        // Add placeholder text
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Camera Place Holder"
        placeholderLabel.textColor = .white
        placeholderLabel.textAlignment = .center
        placeholderLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        placeholderLabel.center = view.center
        view.addSubview(placeholderLabel)
        
        // Add mock body skeleton with chest highlighted
        let skeletonView = UIImageView(frame: CGRect(x: view.bounds.width/2 - 50, y: view.bounds.height - 200, width: 100, height: 180))
        skeletonView.contentMode = .scaleAspectFit
        skeletonView.image = UIImage(systemName: "figure.stand")
        skeletonView.tintColor = .green
        view.addSubview(skeletonView)
        
        // Add chest indicator (a small red dot)
        let chestIndicator = UIView(frame: CGRect(x: view.bounds.width/2 - 5, y: view.bounds.height - 140, width: 10, height: 10))
        chestIndicator.backgroundColor = .red
        chestIndicator.layer.cornerRadius = 5
        view.addSubview(chestIndicator)
    }
    
    // Initialize and configure the AR view
    private func setupARView() {
        // Create AR scene view with device camera background
        arView = ARSCNView(frame: view.bounds)
        arView.delegate = self       // Handle rendering events
        arView.session.delegate = self // Handle session events
        arView.autoenablesDefaultLighting = true  // Add basic lighting
        view.addSubview(arView)
        
        // Configure AR session with advanced features
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]  // Detect surfaces
        configuration.environmentTexturing = .automatic  // Enable reflections
        
        // Enable body tracking if available
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.bodyDetection) {
            configuration.frameSemantics.insert(.bodyDetection)
        }
        
        // Start AR session
        arView.session.run(configuration)
    }
    
    // Set up UI elements like buttons and labels
    private func setupUI() {
        // Back button in top left
        let backButton = UIButton(type: .system)
        backButton.setTitle("<back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 20, y: 40, width: 80, height: 30)
        view.addSubview(backButton)
        
        // Camera button for selecting images
        let cameraButton = UIButton(type: .system)
        cameraButton.backgroundColor = .white
        cameraButton.layer.cornerRadius = 25
        cameraButton.layer.borderWidth = 2
        cameraButton.layer.borderColor = UIColor.lightGray.cgColor
        cameraButton.frame = CGRect(x: view.bounds.width - 70, y: view.bounds.height / 2 - 25, width: 50, height: 50)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        // Body tracking toggle button
        let bodyTrackingButton = UIButton(type: .system)
        bodyTrackingButton.setTitle("Body Tracking", for: .normal)
        bodyTrackingButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        bodyTrackingButton.setTitleColor(.white, for: .normal)
        bodyTrackingButton.layer.cornerRadius = 8
        bodyTrackingButton.frame = CGRect(x: view.bounds.width - 120, y: view.bounds.height - 100, width: 100, height: 40)
        bodyTrackingButton.addTarget(self, action: #selector(toggleBodyTracking), for: .touchUpInside)
        view.addSubview(bodyTrackingButton)
    }
    
    // Set up gesture recognizers for interacting with the 3D model
    private func setupGestureRecognizers() {
        // Pinch gesture for scaling the model
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        // Rotation gesture for rotating the model
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        // Double-tap gesture for resetting the model
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        arView.addGestureRecognizer(tapGesture)
        
        //Add the pan gesture recognizer here:
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let modelNode = modelNode else { return }

        let location = gesture.location(in: arView)
        let results = arView.hitTest(location, types: [.existingPlaneUsingExtent, .featurePoint])

        if let result = results.first {
            let newTransform = result.worldTransform
            let newPosition = SCNVector3(
                newTransform.columns.3.x,
                newTransform.columns.3.y,
                newTransform.columns.3.z
            )

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            modelNode.position = newPosition
            SCNTransaction.commit()

            // ✅ Set this to stop snapping to chest
            userHasMovedImage = true
        }
    }


    // Set up environmental mapping for realistic reflections
    private func setupEnvironmentMapping() {
        // Enable automatic lighting updates based on environment
        arView.automaticallyUpdatesLighting = true
        
        // Create a physically-based material for realistic rendering
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.5  // How metallic the surface appears
        material.roughness.contents = 0.2  // How smooth/rough the surface is
        material.isDoubleSided = true      // Render both sides of surfaces
        
        // Store the material for later use with textures
        environmentMaterial = material
    }
    
    // Add UI controls for adjusting the image/texture
    private func addInteractiveElements() {
        // reset button to open filter selector
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.layer.cornerRadius = 8
        resetButton.frame = CGRect(x: 20, y: view.bounds.height - 100, width: 80, height: 40)
        resetButton.addTarget(self, action: #selector(resetModelPosition), for: .touchUpInside)
        view.addSubview(resetButton)
        
        // Opacity slider for adjusting transparency
        let opacitySlider = UISlider()
        opacitySlider.minimumValue = 0.0
        opacitySlider.maximumValue = 1.0
        opacitySlider.value = 1.0
        opacitySlider.frame = CGRect(x: 120, y: view.bounds.height - 100, width: 120, height: 40)
        opacitySlider.addTarget(self, action: #selector(opacityChanged(_:)), for: .valueChanged)
        view.addSubview(opacitySlider)
    }
    
    // Create and position the 3D model
    private func loadAndPlaceModel() {
        // Create a plane instead of a box for better image projection
        let planeGeometry = SCNPlane(width: 0.2, height: 0.2)  // Size appropriate for chest
        planeGeometry.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.7)
        modelNode = SCNNode(geometry: planeGeometry)
        
        // Position the model in front of the camera initially
        // (will be repositioned to chest when body tracking activates)
        modelNode?.position = SCNVector3(0, 0, -0.5)
        
        // Add the model to the AR scene
        if let modelNode = modelNode {
            arView.scene.rootNode.addChildNode(modelNode)
        }
    }
    
    // Set up body tracking functionality
    private func setupBodyTracking() {
        // Create a node group to represent the skeleton
        skeletonNode = SCNNode()
        
        // Create joints for the skeleton
        createSkeletonJoints()
        
        // Add skeleton to the scene
        if let skeletonNode = skeletonNode {
            arView.scene.rootNode.addChildNode(skeletonNode)
        }
    }
    
    // Create the joints for the body skeleton
    private func createSkeletonJoints() {
        // Create nodes for major body joints
        let jointRadius: CGFloat = 0.025
        let jointColor = UIColor.green
        let chestJointColor = UIColor.red  // Highlight chest joint with different color
        
        // Create a visual representation for a joint
        func createJointNode(isChest: Bool = false) -> SCNNode {
            let geometry = SCNSphere(radius: jointRadius)
            geometry.firstMaterial?.diffuse.contents = isChest ? chestJointColor : jointColor
            let node = SCNNode(geometry: geometry)
            return node
        }
        
        // Create key joints
        let head = createJointNode()
        let neck = createJointNode()
        let leftShoulder = createJointNode()
        let rightShoulder = createJointNode()
        let leftElbow = createJointNode()
        let rightElbow = createJointNode()
        let leftWrist = createJointNode()
        let rightWrist = createJointNode()
        let spine = createJointNode(isChest: true)  // This will be our chest anchor
        let leftHip = createJointNode()
        let rightHip = createJointNode()
        let leftKnee = createJointNode()
        let rightKnee = createJointNode()
        let leftAnkle = createJointNode()
        let rightAnkle = createJointNode()
        
        // Store specific names for important joints
        head.name = "head"
        neck.name = "neck"
        leftShoulder.name = "leftShoulder"
        rightShoulder.name = "rightShoulder"
        leftElbow.name = "leftElbow"
        rightElbow.name = "rightElbow"
        leftWrist.name = "leftWrist"
        rightWrist.name = "rightWrist"
        spine.name = "spine"  // This is our chest reference
        leftHip.name = "leftHip"
        rightHip.name = "rightHip"
        leftKnee.name = "leftKnee"
        rightKnee.name = "rightKnee"
        leftAnkle.name = "leftAnkle"
        rightAnkle.name = "rightAnkle"
        
        // Add joints to skeleton node
        [head, neck, leftShoulder, rightShoulder, leftElbow, rightElbow,
         leftWrist, rightWrist, spine, leftHip, rightHip, leftKnee,
         rightKnee, leftAnkle, rightAnkle].forEach { joint in
            skeletonNode?.addChildNode(joint)
        }
        
        // Create bones (connections between joints)
        createBoneBetween(joint1: head, joint2: neck, color: jointColor)
        createBoneBetween(joint1: neck, joint2: leftShoulder, color: jointColor)
        createBoneBetween(joint1: neck, joint2: rightShoulder, color: jointColor)
        createBoneBetween(joint1: leftShoulder, joint2: leftElbow, color: jointColor)
        createBoneBetween(joint1: rightShoulder, joint2: rightElbow, color: jointColor)
        createBoneBetween(joint1: leftElbow, joint2: leftWrist, color: jointColor)
        createBoneBetween(joint1: rightElbow, joint2: rightWrist, color: jointColor)
        createBoneBetween(joint1: neck, joint2: spine, color: chestJointColor)  // Highlight chest connection
        createBoneBetween(joint1: spine, joint2: leftHip, color: jointColor)
        createBoneBetween(joint1: spine, joint2: rightHip, color: jointColor)
        createBoneBetween(joint1: leftHip, joint2: leftKnee, color: jointColor)
        createBoneBetween(joint1: rightHip, joint2: rightKnee, color: jointColor)
        createBoneBetween(joint1: leftKnee, joint2: leftAnkle, color: jointColor)
        createBoneBetween(joint1: rightKnee, joint2: rightAnkle, color: jointColor)
    }
    
    // Create a visual bone between two joints
    private func createBoneBetween(joint1: SCNNode, joint2: SCNNode, color: UIColor) {
        // This will be called during AR session updates to create/update bones
        let bone = SCNNode()
        bone.name = "bone-\(joint1.name ?? "")-\(joint2.name ?? "")"
        skeletonNode?.addChildNode(bone)
    }
    
    // Update a bone's position and orientation between two joints
    private func updateBone(bone: SCNNode, from startJoint: SCNNode, to endJoint: SCNNode) {
        // Get positions of the joints
        let startPos = startJoint.worldPosition
        let endPos = endJoint.worldPosition
        
        // Calculate distance
        let distance = startPos.distance(to: endPos)
        
        // Remove any existing bone geometry
        bone.geometry = nil
        
        // Create a cylinder between the joints
        let cylinder = SCNCylinder(radius: 0.01, height: CGFloat(distance))
        cylinder.firstMaterial?.diffuse.contents = UIColor.green
        
        // If this is a bone connected to the chest (spine), highlight it
        if startJoint.name == "spine" || endJoint.name == "spine" {
            cylinder.firstMaterial?.diffuse.contents = UIColor.red
        }
        
        bone.geometry = cylinder
        
        // Position and orient the bone
        bone.position = SCNVector3(
            (startPos.x + endPos.x) / 2,
            (startPos.y + endPos.y) / 2,
            (startPos.z + endPos.z) / 2
        )
        
        // Orient the bone to point from start to end joint
        bone.look(at: endPos, up: arView.scene.rootNode.worldUp, localFront: SCNVector3(0, 1, 0))
    }
    
    // Update skeleton position based on detected body
    private func updateBodySkeleton(with bodyAnchor: ARBodyAnchor) {
        // Update position of each joint
        for (index, jointName) in bodyAnchor.skeleton.definition.jointNames.enumerated() {
            if let joint = skeletonNode?.childNode(withName: jointName, recursively: true) {
                let transform = bodyAnchor.skeleton.jointModelTransforms[index]
                joint.simdTransform = bodyAnchor.transform * transform
            }
        }
        
        // Update bones between joints
        skeletonNode?.childNodes.forEach { node in
            if node.name?.starts(with: "bone-") == true {
                let parts = node.name?.split(separator: "-")
                if parts?.count == 3,
                   let joint1 = skeletonNode?.childNode(withName: String(parts![1]), recursively: true),
                   let joint2 = skeletonNode?.childNode(withName: String(parts![2]), recursively: true) {
                    
                    updateBone(bone: node, from: joint1, to: joint2)
                }
            }
        }
    }
    
    // Anchor the model to the chest (spine joint)
    private func anchorModelToChest(with bodyAnchor: ARBodyAnchor) {
        // Find the spine joint index (representing the chest)
        if let spineIndex = bodyAnchor.skeleton.definition.jointNames.firstIndex(of: "spine") {
            let spineTransform = bodyAnchor.skeleton.jointModelTransforms[spineIndex]
            let worldTransform = bodyAnchor.transform * spineTransform

            // Extract only position from the matrix
            let position = SCNVector3(
                worldTransform.columns.3.x,
                worldTransform.columns.3.y,
                worldTransform.columns.3.z - 0.1 // Move slightly forward so it's not inside the chest
            )

            // Apply position and manually set rotation to zero
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1

            modelNode?.position = position
            modelNode?.eulerAngles = SCNVector3(0, 0, 0) // Always face forward

            SCNTransaction.commit()
        }
    }

    // Process the selected image before applying it as a texture
    private func processImageForTexturing(image: UIImage) -> UIImage {
        // Create a CIImage from the UIImage for processing
        guard let ciImage = CIImage(image: image) else { return image }
        
        // Create a context to perform image processing
        let context = CIContext()
        
        // Apply filters to enhance the image
        let filters = ciImage
            .applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: 1.1,      // Slightly increase contrast
                kCIInputBrightnessKey: 0.1,    // Slightly increase brightness
                kCIInputSaturationKey: 1.1     // Slightly increase saturation
            ])
        
        // Convert processed CIImage back to UIImage
        if let outputImage = context.createCGImage(filters, from: filters.extent) {
            return UIImage(cgImage: outputImage)
        }
        
        return image
    }
    
    // Apply the processed image to the chest-anchored model
    private func applyImageToModel(image: UIImage) {
        // Process the image to enhance it
        let processedImage = processImageForTexturing(image: image)
        
        // Create material with the image
        let material = SCNMaterial()
        material.diffuse.contents = processedImage
        material.isDoubleSided = true  // Make visible from both sides
        
        // Apply to model geometry
        modelNode?.geometry?.materials = [material]
    }
    
    // Apply a filter effect to the current image
//    private func applyFilter(_ filterName: String) {
//        guard let image = uploadedImage else { return }
//        
//        // Skip processing if "None" selected
//        if filterName == "None" {
//            applyImageToModel(image: image)
//            return
//        }
//        
//        // Create a CIContext for image processing
//        let context = CIContext()
//        guard let ciImage = CIImage(image: image) else { return }
//        
//        // Apply selected filter based on name
//        var filteredImage: CIImage?
//        switch filterName {
//        case "Sepia":
//            filteredImage = ciImage.applyingFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.8])
//        case "Noir":
//            filteredImage = ciImage.applyingFilter("CIPhotoEffectNoir", parameters: [:])
//        case "Chrome":
//            filteredImage = ciImage.applyingFilter("CIPhotoEffectChrome", parameters: [:])
//        case "Fade":
//            filteredImage = ciImage.applyingFilter("CIPhotoEffectFade", parameters: [:])
//        default:
//            filteredImage = ciImage
//        }
//        
//        // Convert the filtered CIImage back to UIImage
//        if let filteredImage = filteredImage,
//           let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
//            let processedImage = UIImage(cgImage: cgImage)
//            applyImageToModel(image: processedImage)
//        }
//    }
    
    // MARK: - Action Handlers
    @objc private func resetModelPosition() {
        // Allow AR to keep snapping the model again after this
        userHasMovedImage = false

        // Immediately re-anchor the model to the chest if available
        if let frame = arView.session.currentFrame,
           let bodyAnchor = frame.anchors.compactMap({ $0 as? ARBodyAnchor }).first {
            anchorModelToChest(with: bodyAnchor)
        }
    }


    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cameraButtonTapped() {
        // Open image picker to select an image
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func toggleBodyTracking() {
        skeletonNode?.isHidden.toggle()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // Reset model position, scale, and rotation
        modelNode?.position = SCNVector3(0, 0, -0.5)
        modelNode?.scale = SCNVector3(1, 1, 1)
        modelNode?.eulerAngles = SCNVector3(0, 0, 0)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let modelNode = self.modelNode else { return }
        
        // Save initial scale when gesture begins
        if gesture.state == .began {
            initialScale = CGFloat(modelNode.scale.x)
        }
        
        // Calculate and apply new scale
        let newScale = Float(initialScale * gesture.scale)
        modelNode.scale = SCNVector3(newScale, newScale, newScale)
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let modelNode = self.modelNode else { return }
        
        // Save initial rotation when gesture begins
        if gesture.state == .began {
            currentRotation = modelNode.eulerAngles.y
        }
        
        // Calculate and apply new rotation
        let rotation = Float(gesture.rotation)
        modelNode.eulerAngles.y = currentRotation + rotation
    }
    
//    @objc private func showFilters() {
//        // Create an action sheet with filter options
//        let alertController = UIAlertController(title: "Select Filter", message: nil, preferredStyle: .actionSheet)
//        
//        // Add different filter options
//        let filters = ["None", "Sepia", "Noir", "Chrome", "Fade"]
//        for filter in filters {
//            alertController.addAction(UIAlertAction(title: filter, style: .default) { [weak self] _ in
//                self?.applyFilter(filter)
//            })
//        }
//        
//        // Add cancel option
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alertController, animated: true)
//    }
    
    @objc private func opacityChanged(_ slider: UISlider) {
        // Update texture opacity/transparency
        if let material = modelNode?.geometry?.materials.first {
            material.transparency = CGFloat(slider.value)
        }
    }
    
    // MARK: - ARSessionDelegate Methods
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Check for body tracking data
        guard let bodyAnchor = frame.anchors.compactMap({ $0 as? ARBodyAnchor }).first else {
            return
        }
        
        // Update skeleton with the body tracking data
        DispatchQueue.main.async {
            self.updateBodySkeleton(with: bodyAnchor)
            self.anchorModelToChest(with: bodyAnchor)  // Anchor model to chest
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the selected image
        if let selectedImage = info[.originalImage] as? UIImage {
            // Store the original image
            uploadedImage = selectedImage
            
            // Apply it to the 3D model
            applyImageToModel(image: selectedImage)
        }
        
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker if canceled
        dismiss(animated: true, completion: nil)
    }
}

// Calculate distance between two 3D points
extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        let dx = self.x - vector.x
        let dy = self.y - vector.y
        let dz = self.z - vector.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
}

// Preview provider for SwiftUI canvas
struct ARScreen_Previews: PreviewProvider {
    static var previews: some View {
        ARScreen()
    }
}
