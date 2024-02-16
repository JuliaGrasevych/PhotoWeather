

import CoreLocation
import Foundation
import NeedleFoundation
import SwiftUI

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Traversal Helpers

private func parent1(_ component: NeedleFoundation.Scope) -> NeedleFoundation.Scope {
    return component.parent
}

private func parent2(_ component: NeedleFoundation.Scope) -> NeedleFoundation.Scope {
    return component.parent.parent
}

private func parent3(_ component: NeedleFoundation.Scope) -> NeedleFoundation.Scope {
    return component.parent.parent.parent
}

// MARK: - Providers

#if !NEEDLE_DYNAMIC

private class ForecastComponentDependencye48cb9656c6785df1822Provider: ForecastComponentDependency {
    var networkService: NetworkServiceProtocol {
        return rootComponent.networkService
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent
private func factory86564a6fad5198b6d013b3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastComponentDependencye48cb9656c6785df1822Provider(rootComponent: parent1(component) as! RootComponent)
}
private class ForecastLocationItemDependency82611c29f5e1ee9b87d6Provider: ForecastLocationItemDependency {
    var weatherFetcher: ForecastFetching {
        return forecastComponent.weatherFetcher
    }
    var photoFetcher: PhotoStockFetching {
        return rootComponent.photoFetcher
    }
    private let forecastComponent: ForecastComponent
    private let rootComponent: RootComponent
    init(forecastComponent: ForecastComponent, rootComponent: RootComponent) {
        self.forecastComponent = forecastComponent
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent->ForecastLocationItemComponent
private func factory7b5a985098510ca0e8780ddef189803d21e8f8d8(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationItemDependency82611c29f5e1ee9b87d6Provider(forecastComponent: parent2(component) as! ForecastComponent, rootComponent: parent3(component) as! RootComponent)
}
private class ForecastListDependency5440bb37a7e976e93088Provider: ForecastListDependency {
    var weatherFetcher: ForecastFetching {
        return forecastComponent.weatherFetcher
    }
    var photoFetcher: PhotoStockFetching {
        return rootComponent.photoFetcher
    }
    private let forecastComponent: ForecastComponent
    private let rootComponent: RootComponent
    init(forecastComponent: ForecastComponent, rootComponent: RootComponent) {
        self.forecastComponent = forecastComponent
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent
private func factoryce735b6ba16cf6375ceca64e87904111336e27d0(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastListDependency5440bb37a7e976e93088Provider(forecastComponent: parent1(component) as! ForecastComponent, rootComponent: parent2(component) as! RootComponent)
}
private class PhotoStockComponentDependency4c4ae33c040d2d8a8bfcProvider: PhotoStockComponentDependency {
    var networkService: NetworkServiceProtocol {
        return rootComponent.networkService
    }
    var apiKeyProvider: FlickrAPIKeyProviding {
        return rootComponent.apiKeyProvider
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->PhotoStockComponent
private func factory18332b7f0337893519d5b3a8f24c1d289f2c0f2e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return PhotoStockComponentDependency4c4ae33c040d2d8a8bfcProvider(rootComponent: parent1(component) as! RootComponent)
}

#else
extension ForecastComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastComponentDependency.networkService] = "networkService-NetworkServiceProtocol"
        localTable["weatherFetcher-ForecastFetching"] = { [unowned self] in self.weatherFetcher as Any }
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
    }
}
extension ForecastLocationItemComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastLocationItemDependency.weatherFetcher] = "weatherFetcher-ForecastFetching"
        keyPathToName[\ForecastLocationItemDependency.photoFetcher] = "photoFetcher-PhotoStockFetching"
    }
}
extension ForecastListComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastListDependency.weatherFetcher] = "weatherFetcher-ForecastFetching"
        keyPathToName[\ForecastListDependency.photoFetcher] = "photoFetcher-PhotoStockFetching"

    }
}
extension RootComponent: Registration {
    public func registerItems() {

        localTable["networkService-NetworkServiceProtocol"] = { [unowned self] in self.networkService as Any }
        localTable["apiKeyProvider-FlickrAPIKeyProviding"] = { [unowned self] in self.apiKeyProvider as Any }
        localTable["photoFetcher-PhotoStockFetching"] = { [unowned self] in self.photoFetcher as Any }
    }
}
extension PhotoStockComponent: Registration {
    public func registerItems() {
        keyPathToName[\PhotoStockComponentDependency.networkService] = "networkService-NetworkServiceProtocol"
        keyPathToName[\PhotoStockComponentDependency.apiKeyProvider] = "apiKeyProvider-FlickrAPIKeyProviding"
    }
}


#endif

private func factoryEmptyDependencyProvider(_ component: NeedleFoundation.Scope) -> AnyObject {
    return EmptyDependencyProvider(component: component)
}

// MARK: - Registration
private func registerProviderFactory(_ componentPath: String, _ factory: @escaping (NeedleFoundation.Scope) -> AnyObject) {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: componentPath, factory)
}

#if !NEEDLE_DYNAMIC

@inline(never) private func register1() {
    registerProviderFactory("^->RootComponent->ForecastComponent", factory86564a6fad5198b6d013b3a8f24c1d289f2c0f2e)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent->ForecastLocationItemComponent", factory7b5a985098510ca0e8780ddef189803d21e8f8d8)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent", factoryce735b6ba16cf6375ceca64e87904111336e27d0)
    registerProviderFactory("^->RootComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootComponent->PhotoStockComponent", factory18332b7f0337893519d5b3a8f24c1d289f2c0f2e)
}
#endif

public func registerProviderFactories() {
#if !NEEDLE_DYNAMIC
    register1()
#endif
}
