

import Combine
import Core
import CoreLocation
import Forecast
import ForecastDependency
import Foundation
import NeedleFoundation
import PhotoStock
import PhotoStockDependency
import Storage
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

private class ForecastComponentDependency342ec1246a5e0294e566Provider: ForecastComponentDependency {
    var networkService: NetworkServiceProtocol {
        return rootReactiveComponent.networkService
    }
    private let rootReactiveComponent: RootReactiveComponent
    init(rootReactiveComponent: RootReactiveComponent) {
        self.rootReactiveComponent = rootReactiveComponent
    }
}
/// ^->RootReactiveComponent->ForecastReactiveComponent
private func factory1e61e324b043bdbac345bacfcca18711825e3a4e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastComponentDependency342ec1246a5e0294e566Provider(rootReactiveComponent: parent1(component) as! RootReactiveComponent)
}
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
private class ForecastAddLocationReactiveDependency7f377ec4590efcc5c3c0Provider: ForecastAddLocationReactiveDependency {
    var locationStorage: LocationStoringReactive {
        return rootReactiveComponent.locationStorage
    }
    private let rootReactiveComponent: RootReactiveComponent
    init(rootReactiveComponent: RootReactiveComponent) {
        self.rootReactiveComponent = rootReactiveComponent
    }
}
/// ^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastAddLocationReactiveComponent
private func factory8b3940fa560b2e58d9050c7717717e1dd9313958(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastAddLocationReactiveDependency7f377ec4590efcc5c3c0Provider(rootReactiveComponent: parent3(component) as! RootReactiveComponent)
}
private class ForecastLocationSearchReactiveDependency4532067ed7e6a1e5ea1cProvider: ForecastLocationSearchReactiveDependency {
    var locationFinder: LocationSearchingReactive {
        return forecastAddLocationReactiveComponent.locationFinder
    }
    private let forecastAddLocationReactiveComponent: ForecastAddLocationReactiveComponent
    init(forecastAddLocationReactiveComponent: ForecastAddLocationReactiveComponent) {
        self.forecastAddLocationReactiveComponent = forecastAddLocationReactiveComponent
    }
}
/// ^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastAddLocationReactiveComponent->ForecastLocationSearchReactiveComponent
private func factorycb4bfbaefe614be9f5df450fe7ba33afcdf29c21(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationSearchReactiveDependency4532067ed7e6a1e5ea1cProvider(forecastAddLocationReactiveComponent: parent1(component) as! ForecastAddLocationReactiveComponent)
}
private class ForecastLocationSearchDependencyd0fd584696711db3e3a6Provider: ForecastLocationSearchDependency {
    var locationFinder: LocationSearching {
        return forecastAddLocationComponent.locationFinder
    }
    private let forecastAddLocationComponent: ForecastAddLocationComponent
    init(forecastAddLocationComponent: ForecastAddLocationComponent) {
        self.forecastAddLocationComponent = forecastAddLocationComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent->ForecastAddLocationComponent->ForecastLocationSearchComponent
private func factory608345bf27adcb4b08a7675656a41af65a05573c(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationSearchDependencyd0fd584696711db3e3a6Provider(forecastAddLocationComponent: parent1(component) as! ForecastAddLocationComponent)
}
private class ForecastAddLocationDependency842a162c523bcbb0bb93Provider: ForecastAddLocationDependency {
    var locationStorage: LocationStoring {
        return rootComponent.locationStorage
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent->ForecastAddLocationComponent
private func factory2cea3293fe90ce11468e42f5655bf2362a8495f6(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastAddLocationDependency842a162c523bcbb0bb93Provider(rootComponent: parent3(component) as! RootComponent)
}
private class ForecastLocationItemReactiveDependency68601d4a433b1b09fff5Provider: ForecastLocationItemReactiveDependency {
    var weatherFetcher: ForecastFetchingReactive {
        return forecastReactiveComponent.weatherFetcher
    }
    var photoFetcher: PhotoStockFetchingReactive {
        return rootReactiveComponent.photoFetcher
    }
    var locationManager: LocationManagingReactive {
        return rootReactiveComponent.locationManager
    }
    private let forecastReactiveComponent: ForecastReactiveComponent
    private let rootReactiveComponent: RootReactiveComponent
    init(forecastReactiveComponent: ForecastReactiveComponent, rootReactiveComponent: RootReactiveComponent) {
        self.forecastReactiveComponent = forecastReactiveComponent
        self.rootReactiveComponent = rootReactiveComponent
    }
}
/// ^->RootReactiveComponent->ForecastReactiveComponent->ForecastLocationItemReactiveComponent
private func factory7b975dc1346875af7679f19204f8dc4338d77d07(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationItemReactiveDependency68601d4a433b1b09fff5Provider(forecastReactiveComponent: parent1(component) as! ForecastReactiveComponent, rootReactiveComponent: parent2(component) as! RootReactiveComponent)
}
/// ^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastLocationItemReactiveComponent
private func factory7b975dc1346875af76790406837a51b780cb807e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationItemReactiveDependency68601d4a433b1b09fff5Provider(forecastReactiveComponent: parent2(component) as! ForecastReactiveComponent, rootReactiveComponent: parent3(component) as! RootReactiveComponent)
}
private class ForecastLocationItemDependency7d800bf05f5074f63281Provider: ForecastLocationItemDependency {
    var weatherFetcher: ForecastFetching {
        return forecastComponent.weatherFetcher
    }
    var photoFetcher: PhotoStockFetching {
        return rootComponent.photoFetcher
    }
    var locationManager: LocationManaging {
        return rootComponent.locationManager
    }
    private let forecastComponent: ForecastComponent
    private let rootComponent: RootComponent
    init(forecastComponent: ForecastComponent, rootComponent: RootComponent) {
        self.forecastComponent = forecastComponent
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastLocationItemComponent
private func factory0067ab9cb5a0b6242957a64e87904111336e27d0(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationItemDependency7d800bf05f5074f63281Provider(forecastComponent: parent1(component) as! ForecastComponent, rootComponent: parent2(component) as! RootComponent)
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent->ForecastLocationItemComponent
private func factory0067ab9cb5a0b62429570ddef189803d21e8f8d8(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastLocationItemDependency7d800bf05f5074f63281Provider(forecastComponent: parent2(component) as! ForecastComponent, rootComponent: parent3(component) as! RootComponent)
}
private class ForecastListReactiveDependency54e9f58408d545ba4c5fProvider: ForecastListReactiveDependency {
    var locationStorage: LocationStoringReactive {
        return rootReactiveComponent.locationStorage
    }
    var locationProvider: LocationProvidingReactive {
        return rootReactiveComponent.locationProvider
    }
    private let rootReactiveComponent: RootReactiveComponent
    init(rootReactiveComponent: RootReactiveComponent) {
        self.rootReactiveComponent = rootReactiveComponent
    }
}
/// ^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent
private func factorye38022fbd6cc41abc96528de26410d04920966c4(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastListReactiveDependency54e9f58408d545ba4c5fProvider(rootReactiveComponent: parent2(component) as! RootReactiveComponent)
}
private class ForecastListDependency5440bb37a7e976e93088Provider: ForecastListDependency {
    var locationStorage: LocationStoring {
        return rootComponent.locationStorage
    }
    var locationProvider: LocationProviding {
        return rootComponent.locationProvider
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ForecastComponent->ForecastListComponent
private func factoryce735b6ba16cf6375ceca9403e3301bb54f80df0(_ component: NeedleFoundation.Scope) -> AnyObject {
    return ForecastListDependency5440bb37a7e976e93088Provider(rootComponent: parent2(component) as! RootComponent)
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
private class PhotoStockComponentDependencydf2f587c24fceb89d64cProvider: PhotoStockComponentDependency {
    var networkService: NetworkServiceProtocol {
        return rootReactiveComponent.networkService
    }
    var apiKeyProvider: FlickrAPIKeyProviding {
        return rootReactiveComponent.apiKeyProvider
    }
    private let rootReactiveComponent: RootReactiveComponent
    init(rootReactiveComponent: RootReactiveComponent) {
        self.rootReactiveComponent = rootReactiveComponent
    }
}
/// ^->RootReactiveComponent->PhotoStockComponent
private func factoryfc279b909075d4277b33bacfcca18711825e3a4e(_ component: NeedleFoundation.Scope) -> AnyObject {
    return PhotoStockComponentDependencydf2f587c24fceb89d64cProvider(rootReactiveComponent: parent1(component) as! RootReactiveComponent)
}

#else
extension RootComponent: Registration {
    public func registerItems() {

        localTable["networkService-NetworkServiceProtocol"] = { [unowned self] in self.networkService as Any }
        localTable["apiKeyProvider-FlickrAPIKeyProviding"] = { [unowned self] in self.apiKeyProvider as Any }
        localTable["photoFetcher-PhotoStockFetching"] = { [unowned self] in self.photoFetcher as Any }
        localTable["locationStorage-LocationStoring"] = { [unowned self] in self.locationStorage as Any }
        localTable["locationProvider-LocationProviding"] = { [unowned self] in self.locationProvider as Any }
        localTable["locationManager-LocationManaging"] = { [unowned self] in self.locationManager as Any }
    }
}
extension RootReactiveComponent: Registration {
    public func registerItems() {

        localTable["networkService-NetworkServiceProtocol"] = { [unowned self] in self.networkService as Any }
        localTable["apiKeyProvider-FlickrAPIKeyProviding"] = { [unowned self] in self.apiKeyProvider as Any }
        localTable["photoFetcher-PhotoStockFetchingReactive"] = { [unowned self] in self.photoFetcher as Any }
        localTable["locationStorage-LocationStoringReactive"] = { [unowned self] in self.locationStorage as Any }
        localTable["locationProvider-LocationProvidingReactive"] = { [unowned self] in self.locationProvider as Any }
        localTable["locationManager-LocationManagingReactive"] = { [unowned self] in self.locationManager as Any }
    }
}
extension StorageComponent: Registration {
    public func registerItems() {

    }
}
extension ForecastReactiveComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastComponentDependency.networkService] = "networkService-NetworkServiceProtocol"
        localTable["weatherFetcher-ForecastFetchingReactive"] = { [unowned self] in self.weatherFetcher as Any }
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
    }
}
extension ForecastComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastComponentDependency.networkService] = "networkService-NetworkServiceProtocol"
        localTable["weatherFetcher-ForecastFetching"] = { [unowned self] in self.weatherFetcher as Any }
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
    }
}
extension ForecastAddLocationReactiveComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastAddLocationReactiveDependency.locationStorage] = "locationStorage-LocationStoringReactive"
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
        localTable["locationFinder-LocationSearchingReactive"] = { [unowned self] in self.locationFinder as Any }
    }
}
extension ForecastLocationSearchReactiveComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastLocationSearchReactiveDependency.locationFinder] = "locationFinder-LocationSearchingReactive"
    }
}
extension ForecastLocationSearchComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastLocationSearchDependency.locationFinder] = "locationFinder-LocationSearching"
    }
}
extension ForecastAddLocationComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastAddLocationDependency.locationStorage] = "locationStorage-LocationStoring"
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
        localTable["locationFinder-LocationSearching"] = { [unowned self] in self.locationFinder as Any }
    }
}
extension ForecastLocationItemReactiveComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastLocationItemReactiveDependency.weatherFetcher] = "weatherFetcher-ForecastFetchingReactive"
        keyPathToName[\ForecastLocationItemReactiveDependency.photoFetcher] = "photoFetcher-PhotoStockFetchingReactive"
        keyPathToName[\ForecastLocationItemReactiveDependency.locationManager] = "locationManager-LocationManagingReactive"
    }
}
extension ForecastLocationItemComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastLocationItemDependency.weatherFetcher] = "weatherFetcher-ForecastFetching"
        keyPathToName[\ForecastLocationItemDependency.photoFetcher] = "photoFetcher-PhotoStockFetching"
        keyPathToName[\ForecastLocationItemDependency.locationManager] = "locationManager-LocationManaging"
    }
}
extension ForecastListReactiveComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastListReactiveDependency.locationStorage] = "locationStorage-LocationStoringReactive"
        keyPathToName[\ForecastListReactiveDependency.locationProvider] = "locationProvider-LocationProvidingReactive"
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
    }
}
extension ForecastListComponent: Registration {
    public func registerItems() {
        keyPathToName[\ForecastListDependency.locationStorage] = "locationStorage-LocationStoring"
        keyPathToName[\ForecastListDependency.locationProvider] = "locationProvider-LocationProviding"
        localTable["view-AnyView"] = { [unowned self] in self.view as Any }
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
    registerProviderFactory("^->RootComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootReactiveComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootComponent->StorageComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootReactiveComponent->StorageComponent", factoryEmptyDependencyProvider)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent", factory1e61e324b043bdbac345bacfcca18711825e3a4e)
    registerProviderFactory("^->RootComponent->ForecastComponent", factory86564a6fad5198b6d013b3a8f24c1d289f2c0f2e)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastAddLocationReactiveComponent", factory8b3940fa560b2e58d9050c7717717e1dd9313958)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastAddLocationReactiveComponent->ForecastLocationSearchReactiveComponent", factorycb4bfbaefe614be9f5df450fe7ba33afcdf29c21)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent->ForecastAddLocationComponent->ForecastLocationSearchComponent", factory608345bf27adcb4b08a7675656a41af65a05573c)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent->ForecastAddLocationComponent", factory2cea3293fe90ce11468e42f5655bf2362a8495f6)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent->ForecastLocationItemReactiveComponent", factory7b975dc1346875af7679f19204f8dc4338d77d07)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent->ForecastLocationItemReactiveComponent", factory7b975dc1346875af76790406837a51b780cb807e)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastLocationItemComponent", factory0067ab9cb5a0b6242957a64e87904111336e27d0)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent->ForecastLocationItemComponent", factory0067ab9cb5a0b62429570ddef189803d21e8f8d8)
    registerProviderFactory("^->RootReactiveComponent->ForecastReactiveComponent->ForecastListReactiveComponent", factorye38022fbd6cc41abc96528de26410d04920966c4)
    registerProviderFactory("^->RootComponent->ForecastComponent->ForecastListComponent", factoryce735b6ba16cf6375ceca9403e3301bb54f80df0)
    registerProviderFactory("^->RootComponent->PhotoStockComponent", factory18332b7f0337893519d5b3a8f24c1d289f2c0f2e)
    registerProviderFactory("^->RootReactiveComponent->PhotoStockComponent", factoryfc279b909075d4277b33bacfcca18711825e3a4e)
}
#endif

public func registerProviderFactories() {
#if !NEEDLE_DYNAMIC
    register1()
#endif
}
