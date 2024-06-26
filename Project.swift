import ProjectDescription

extension Target {
    static func appTarget(
        _ name: String,
        bundleIdPath: String? = nil,
        path: String? = nil,
        product: Product,
        infoPlist: InfoPlist? = .default,
        additionalSources: [String] = [],
        additionalResources: [String] = [],
        hasResources: Bool = false,
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        let frameworkPath = path ?? name
        var sourcesPaths: [String] = (hasResources ? ["\(frameworkPath)/Sources/**"] : ["\(frameworkPath)/**"]) + additionalSources
        let sources: SourceFilesList = SourceFilesList.paths(sourcesPaths.map { Path(stringLiteral: $0) })
        let resourcesPaths: [String] = (hasResources ? ["\(frameworkPath)/Resources/**"] : []) + additionalResources
        let resources: ResourceFileElements? = resourcesPaths.isEmpty
        ? nil
        : ResourceFileElements.resources( resourcesPaths.map { ResourceFileElement(stringLiteral: $0) })
        return .target(
            name: name,
            destinations: [.iPhone],
            product: product,
            bundleId: "com.julia.\(bundleIdPath ?? name)",
            deploymentTargets: .iOS("17.0"),
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            scripts: scripts,
            dependencies: dependencies,
            settings: settings
        )
    }
    
    static func app(
        _ name: String,
        infoPlist: InfoPlist? = .default,
        additionalSources: [String] = [],
        additionalResources: [String] = [],
        entitlements: Entitlements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        .appTarget(
            name,
            product: .app,
            infoPlist: infoPlist,
            additionalSources: additionalSources,
            additionalResources: additionalResources,
            hasResources: true,
            entitlements: entitlements,
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
        .appTarget(
            "PhotoWeatherWidget",
            bundleIdPath: "PhotoWeather.extension",
            product: .appExtension,
            infoPlist: .file(path: "PhotoWeatherWidget/Info.plist"),
            additionalSources: ["Shared/Sources/**"],
            entitlements: Entitlements.dictionary(
                ["com.apple.security.application-groups": Plist.Value(arrayLiteral: "group.com.julia.PhotoWeather")]
            ),
            dependencies: [
                .target(name: "Core"),
                .target(name: "Forecast"),
                .target(name: "ForecastDependency"),
                .target(name: "PhotoStock"),
                .target(name: "PhotoStockDependency"),
                .target(name: "Storage"),
                .external(name: "NeedleFoundation"),
                .sdk(name: "SwiftUI", type: .framework),
                .sdk(name: "WidgetKit", type: .framework)
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/PhotoWeatherWidget.xcconfig")
                ]
            )
        ),
        .app(
            "PhotoWeather",
            infoPlist: .extendingDefault(
                with: [
                    "FLICKR_API_KEY": "$(FLICKR_API_KEY)",
                    "NSLocationWhenInUseUsageDescription": "Allow access to user location to get weather for your city",
                    "CFBundleVersion": "0.1",
                    "CFBundleShortVersionString": "0.1",
                    "UILaunchStoryboardName": "Launch Screen.storyboard"
                ]
            ),
            additionalSources: ["Shared/Sources/**"],
            entitlements: Entitlements.dictionary(
                ["com.apple.security.application-groups": Plist.Value(arrayLiteral: "group.com.julia.PhotoWeather")]
            ),
            scripts: [
                .pre(
                    script: "export SOURCEKIT_LOGGING=0 && needle generate Shared/Sources/DI/NeedleGenerated.swift ./",
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
                .external(name: "NeedleFoundation"),
                .target(name: "PhotoWeatherWidget")
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: "Configs/PhotoWeatherApp.xcconfig")
                ]
            )
        )
    ]
)
