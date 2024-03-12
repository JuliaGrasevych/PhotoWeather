// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "NeedleFoundation": .framework,
        ]
    )
#endif

let package = Package(
    name: "Tuist",
    dependencies: [
        .package(url: "https://github.com/uber/needle", .upToNextMajor(from: "0.24.0"))
    ]
)
