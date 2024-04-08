import ProjectDescription

extension Target {
    static func appTarget(
        _ name: String,
        path: String? = nil,
        product: Product,
        infoPlist: InfoPlist? = .default,
        hasResources: Bool = false,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        let frameworkPath = path ?? name
        let sources: SourceFilesList = hasResources ? ["\(frameworkPath)/Sources/**"] : ["\(frameworkPath)/**"]
        let resources: ResourceFileElements? = hasResources ? ["\(frameworkPath)/Resources/**"] : nil
        return .target(
            name: name,
            destinations: [.iPhone],
            product: product,
            bundleId: "com.julia.\(name)",
            deploymentTargets: .iOS("17.0"),
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings
        )
    }
    
    static func app(
        _ name: String,
        infoPlist: InfoPlist? = .default,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        .appTarget(
            name,
            product: .app,
            infoPlist: infoPlist,
            hasResources: true,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings
        )
    }
    
    static func framework(
        _ name: String,
        path: String? = nil,
        hasResources: Bool = false,
        dependencies: [TargetDependency] = []
    ) -> Target {
        return .appTarget(
            name,
            path: path,
            product: .framework,
            hasResources: hasResources,
            dependencies: dependencies
        )
    }
    
    static func dependencyFramework(
        _ name: String,
        hasResources: Bool = false,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .framework(
            name,
            path: "Dependency/\(name)",
            hasResources: hasResources,
            dependencies: dependencies
        )
    }
    
    static func moduleFramework(
        _ name: String,
        hasResources: Bool = false,
        dependencies: [TargetDependency] = []
    ) -> Target {
        .framework(
            name,
            path: "Modules/\(name)",
            hasResources: hasResources,
            dependencies: dependencies
        )
    }
}

let project = Project(
    name: "PhotoWeather",
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/PhotoWeatherProject.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/PhotoWeatherProject.xcconfig")
        ]
    ),
    targets: [
        .framework("Core"),
        .dependencyFramework("PhotoStockDependency", dependencies: [.target(name: "Core")]),
        .dependencyFramework("ForecastDependency", dependencies: [.target(name: "Core")]),
        .framework(
            "Storage",
            dependencies: [
                .target(name: "Core"),
                .target(name: "ForecastDependency"),
                .external(name: "NeedleFoundation")
            ]
        ),
        .moduleFramework(
            "PhotoStock",
            dependencies: [
                .target(name: "Core"),
                .target(name: "PhotoStockDependency"),
                .external(name: "NeedleFoundation")
            ]
        ),
        .moduleFramework(
            "Forecast",
            hasResources: true,
            dependencies: [
                .target(name: "Core"),
                .target(name: "ForecastDependency"),
                .target(name: "PhotoStockDependency"),
                .external(name: "NeedleFoundation")
            ]
        ),
        .app(
            "PhotoWeather",
            infoPlist: .extendingDefault(
                with: [
                    "FLICKR_API_KEY": "$(FLICKR_API_KEY)",
                    "UIAppFonts": ["weather-icons-lite.ttf"],
                    "NSLocationWhenInUseUsageDescription": "Allow access to user location to get weather for your city",
                    "CFBundleVersion": "0.1",
                    "CFBundleShortVersionString": "0.1",
                    "UILaunchStoryboardName": "Launch Screen.storyboard"
                ]
            ),
            scripts: [
                .pre(
                    script: "export SOURCEKIT_LOGGING=0 && needle generate PhotoWeather/Sources/DI/NeedleGenerated.swift ./",
                    name: "Needle",
                    shellPath: "/bin/sh"
                )
            ],
            dependencies: [
                .target(name: "Core"),
                .target(name: "Forecast"),
                .target(name: "ForecastDependency"),
                .target(name: "PhotoStock"),
                .target(name: "PhotoStockDependency"),
                .target(name: "Storage"),
                .external(name: "NeedleFoundation")
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/PhotoWeatherApp.xcconfig")
                ]
            )
        )
    ]
)
