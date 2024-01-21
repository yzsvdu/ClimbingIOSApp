//
//  ImageUploadView.swift
//  ClimbAppiOSSwiftView
//
//  Created by Vincent Duong on 1/20/24.
//

import SwiftUI

struct ImageUploadView: View {
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Tap to Upload Image")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.cyan)
                    .padding()
            }
            .onTapGesture {
                isImagePickerPresented.toggle()
            }
            .navigationDestination(isPresented: $isImagePickerPresented) {
                ImagePickerView(selectedImage: $selectedImage)
            }
            .preferredColorScheme(ColorScheme.dark)
        }
    }
}


struct ImagePickerView: View {
    @State private var isLibraryPickerPresented: Bool = false
    @State private var isCameraPickerPresented: Bool = false
    @State private var isPreviewImagePresented: Bool = false
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Text("Choose an option:")
                .font(.title)
                .foregroundColor(.white)
                .padding()
            
            Button(action: {
                self.isLibraryPickerPresented.toggle()
            }) {
                Text("Choose from Library")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isLibraryPickerPresented) {
                ImagePicker(isImagePickerPresented: $isLibraryPickerPresented, selectedImage: $selectedImage, isPreviewImagePresented: $isPreviewImagePresented, sourceType: .photoLibrary)
            }
            
            Button(action: {
                self.isCameraPickerPresented.toggle()
            }) {
                Text("Take a Picture")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isCameraPickerPresented) {
                ImagePicker(isImagePickerPresented: $isCameraPickerPresented, selectedImage: $selectedImage, isPreviewImagePresented: $isPreviewImagePresented, sourceType: .camera)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Upload")
        .navigationDestination(isPresented: $isPreviewImagePresented) {
            ReviewImageView(image: selectedImage ?? UIImage())
        }
        .preferredColorScheme(ColorScheme.dark)
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerPresented: Bool
    @Binding var selectedImage: UIImage?
    @Binding var isPreviewImagePresented: Bool
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = sourceType
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image.resizeImageKeepAspect(targetSize: CGSize(width: 960, height: 1280))
                parent.isPreviewImagePresented = true

            }
            parent.isImagePickerPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isImagePickerPresented = false
        }
    }
}

extension UIImage {
    func resizeImageKeepAspect(targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let newWidth = size.width * scaleFactor
        let newHeight = size.height * scaleFactor

        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ImageUploadView()
    }
}
