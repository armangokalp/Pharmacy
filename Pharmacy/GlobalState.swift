import SwiftUI

class GlobalState: ObservableObject {

    static let shared = GlobalState()
    @Published var tabViewTag: Int = 0
    @Published var showHeader: Bool = false
    @EnvironmentObject var vm: locationViewModel
    
    private init() {}
    
    
    func formatText(_ input: String) -> String {
        let words = input.split(separator: " ")
        let capitalizedWords = words.map { word -> String in
            let lower = word.lowercased(with: Locale(identifier: "tr_TR"))
            let first = String(lower.prefix(1)).uppercased(with: Locale(identifier: "tr_TR"))
            let rest = String(lower.dropFirst())
            return first + rest
        }
        return capitalizedWords.joined(separator: " ")
    }
    
}



struct ConditionalSafeAreaModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 16.0, *) {
                content.edgesIgnoringSafeArea(.all)
            } else {
                content.edgesIgnoringSafeArea([.top, .leading, .trailing])
            }
        }
    }
}

extension View {
    func conditionalSafeArea() -> some View {
        self.modifier(ConditionalSafeAreaModifier())
    }
}




struct AsyncImage: View {
    @State private var imageData: Data = Data()
    let url: URL?
    let placeholder: Image

    var body: some View {
        Group {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage).resizable()
            } else {
                placeholder
            }
        }
        .onAppear(perform: downloadImage)
    }

    private func downloadImage() {
        guard let imageUrl = url else { return }
        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
}
