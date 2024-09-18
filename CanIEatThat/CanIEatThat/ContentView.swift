//
//  ContentView.swift
//  CanIEatThat
//
//  Created by Silvia España Gil on 17/9/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var inputImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("Toma una foto del alimento o ingredientes")
            }
            
            Button("Seleccionar Imagen") {
                showingActionSheet = true
            }
            .padding()
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Selecciona una opción"), buttons: [
                    .default(Text("Cámara")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("Galería")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ])
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                if let image = image {
                    self.inputImage = image
                    processImage(image)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Alerta de Alérgeno"), message: Text(alertMessage), dismissButton: .default(Text("OK")){
                self.inputImage = nil
            })
        }
    }
}

extension ContentView {
    
    func checkForAllergens(in text: String, allergens: [String]) -> String? {
        
        for allergen in allergens {
            if text.lowercased().contains(allergen.lowercased()) {
                return allergen
            }
        }
        return nil
    }
    
    func processImage(_ image: UIImage) {
        
        let textRecognizer = AllergenTextRecognizer()
        textRecognizer.recognizeText(in: image) { recognizedText in
            if let text = recognizedText {
                
                let normalizedText = normalizeText(text)
                
                let allergens = ["cacahuete", "mani", "huevo"]
                
                if let detectedAllergen = checkForAllergens(in: normalizedText, allergens: allergens) {
                    
                    self.alertMessage = "Se ha detectado \(detectedAllergen) en los ingredientes."
                } else {
                    self.alertMessage = "No se han detectado alérgenos."
                }
                showingAlert = true
            }
        }
    }
    
    func normalizeText(_ text: String) -> String {
        
        let lowercaseText = text.lowercased()
        
        let removeSpecialCharacters = lowercaseText.folding(options: .diacriticInsensitive, locale: .current)
        
        let cleanedText = removeSpecialCharacters.components(separatedBy: CharacterSet.alphanumerics.inverted.subtracting(CharacterSet.whitespaces)).joined(separator: " ")
        
        return cleanedText
    }
}

#Preview {
    ContentView()
}
