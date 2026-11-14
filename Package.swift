// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "OCBarrage",
    platforms: [.iOS(.v15)],
    products: [.library(name: "OCBarrage", targets: ["OCBarrage"])],
    targets: [.target(name: "OCBarrage", path: "OCBarrage/OCBarrage", sources: [
        "OCBarrageDescriptor.swift", "OCBarrageCell.swift", "OCBarrageRenderView.swift", "OCBarrageManager.swift"
    ])],
    swiftLanguageModes: [.v6]
)
