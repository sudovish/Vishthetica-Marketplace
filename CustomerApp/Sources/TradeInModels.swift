import SwiftUI

enum TradeInFlowMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case cash = "Cash Offer"
    case discount = "Listing Discount"

    var icon: String {
        switch self {
        case .cash: return "dollarsign.circle.fill"
        case .discount: return "tag.fill"
        }
    }
}

enum TradeInDeviceType: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case phone = "Phone"
    case macbook = "MacBook"
    case ipad = "iPad"
    case imac = "iMac"
    case airpods = "AirPods"
    case applewatch = "Apple Watch"
    case gamingLaptop = "Gaming Laptop"
    case monitor = "Monitor"
    case tv = "TV"
    case miscellaneous = "Misc"

    var systemIcon: String {
        switch self {
        case .phone: return "iphone"
        case .macbook: return "laptopcomputer"
        case .ipad: return "ipad"
        case .imac: return "desktopcomputer"
        case .airpods: return "airpodspro"
        case .applewatch: return "applewatch"
        case .gamingLaptop: return "laptopcomputer"
        case .monitor: return "display"
        case .tv: return "tv"
        case .miscellaneous: return "shippingbox"
        }
    }

    var asksBatteryHealth: Bool {
        switch self {
        case .phone, .macbook, .airpods, .applewatch, .gamingLaptop:
            return true
        case .ipad:
            return false
        default:
            return false
        }
    }

    var asksStorage: Bool {
        switch self {
        case .phone, .macbook, .ipad, .imac, .gamingLaptop:
            return true
        default:
            return false
        }
    }

    var asksComputerSpecs: Bool {
        switch self {
        case .macbook, .imac, .gamingLaptop:
            return true
        default:
            return false
        }
    }
}

struct TradeInBrandGroup: Identifiable {
    let id = UUID()
    let brand: String
    let models: [String]
}

enum TradeInCondition: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case forParts = "For Parts"

    var description: String {
        switch self {
        case .excellent: return "Like new, no visible wear, fully functional"
        case .good: return "Minor wear, no major damage, fully functional"
        case .fair: return "Noticeable wear or damage, still usable"
        case .forParts: return "Locked, cracked, liquid damaged, or not powering on"
        }
    }
}

class TradeInState: ObservableObject {
    @Published var selectedMode: TradeInFlowMode = .cash
    @Published var targetListing: Listing? = nil
    @Published var selectedDevice: TradeInDeviceType? = nil
    @Published var selectedBrand: String = ""
    @Published var selectedModel: String = ""
    @Published var selectedCondition: TradeInCondition? = nil
    @Published var batteryHealth: String = ""
    @Published var storage: String = ""
    @Published var ram: String = ""
    @Published var cpu: String = ""
    @Published var notes: String = ""
    @Published var iCloudLocked: Bool = false
    @Published var appleCarePlus: Bool = false
    @Published var photosAttached: Bool = false

    var brandGroups: [TradeInBrandGroup] {
        guard let selectedDevice else { return [] }
        return TradeInCatalog.groups(for: selectedDevice)
    }

    var models: [String] {
        brandGroups.first { $0.brand == selectedBrand }?.models ?? []
    }

    var shouldAskBatteryHealth: Bool {
        guard let selectedDevice else { return false }
        if selectedDevice == .ipad {
            return selectedModel.localizedCaseInsensitiveContains("M4")
        }
        return selectedDevice.asksBatteryHealth
    }

    func chooseDevice(_ device: TradeInDeviceType) {
        selectedDevice = device
        selectedBrand = ""
        selectedModel = ""
        resetSpecs()
    }

    func chooseBrand(_ brand: String) {
        selectedBrand = brand
        selectedModel = ""
        resetSpecs()
    }

    func reset() {
        selectedMode = .cash
        targetListing = nil
        selectedDevice = nil
        selectedBrand = ""
        selectedModel = ""
        resetSpecs()
    }

    private func resetSpecs() {
        selectedCondition = nil
        batteryHealth = ""
        storage = ""
        ram = ""
        cpu = ""
        notes = ""
        iCloudLocked = false
        appleCarePlus = false
        photosAttached = false
    }
}

enum TradeInCatalog {
    static func groups(for device: TradeInDeviceType) -> [TradeInBrandGroup] {
        switch device {
        case .phone:
            return [
                TradeInBrandGroup(brand: "Apple", models: ["iPhone 16 Pro Max", "iPhone 16 Pro", "iPhone 16 Plus", "iPhone 16", "iPhone 15 Pro Max", "iPhone 15 Pro", "iPhone 15 Plus", "iPhone 15", "iPhone 14 Pro Max", "iPhone 14 Pro", "iPhone 14", "iPhone 13 Pro", "iPhone 13", "iPhone 12", "iPhone 11", "iPhone SE"]),
                TradeInBrandGroup(brand: "Samsung", models: ["Galaxy S25 Ultra", "Galaxy S25+", "Galaxy S25", "Galaxy S24 Ultra", "Galaxy S24+", "Galaxy S24", "Galaxy S23 Ultra", "Galaxy Z Fold6", "Galaxy Z Flip6"]),
                TradeInBrandGroup(brand: "Google", models: ["Pixel 9 Pro Fold", "Pixel 9 Pro XL", "Pixel 9 Pro", "Pixel 9", "Pixel 8 Pro", "Pixel 8", "Pixel 7 Pro", "Pixel 7"])
            ]
        case .macbook:
            return [
                TradeInBrandGroup(brand: "Apple Silicon", models: ["MacBook Pro 16-inch M4 Max", "MacBook Pro 16-inch M4 Pro", "MacBook Pro 14-inch M4", "MacBook Air 15-inch M3", "MacBook Air 13-inch M3", "MacBook Air 13-inch M2", "MacBook Pro 14-inch M1 Pro", "MacBook Air 13-inch M1"]),
                TradeInBrandGroup(brand: "Intel", models: ["MacBook Pro 16-inch Intel", "MacBook Pro 15-inch Intel", "MacBook Pro 13-inch Intel", "MacBook Air Intel"])
            ]
        case .ipad:
            return [
                TradeInBrandGroup(brand: "iPad Pro", models: ["iPad Pro 13-inch M4", "iPad Pro 11-inch M4", "iPad Pro 12.9-inch M2", "iPad Pro 11-inch M2", "iPad Pro 12.9-inch M1"]),
                TradeInBrandGroup(brand: "iPad Air", models: ["iPad Air 13-inch M2", "iPad Air 11-inch M2", "iPad Air 5", "iPad Air 4"]),
                TradeInBrandGroup(brand: "iPad / mini", models: ["iPad mini 7", "iPad mini 6", "iPad 10th gen", "iPad 9th gen"])
            ]
        case .imac:
            return [TradeInBrandGroup(brand: "Apple", models: ["iMac 24-inch M4", "iMac 24-inch M3", "iMac 24-inch M1", "iMac 27-inch Intel", "iMac Pro"])]
        case .airpods:
            return [TradeInBrandGroup(brand: "AirPods", models: ["AirPods Pro 2 USB-C", "AirPods Pro 2 Lightning", "AirPods Pro 1", "AirPods 4 ANC", "AirPods 4", "AirPods 3", "AirPods Max"])]
        case .applewatch:
            return [TradeInBrandGroup(brand: "Apple Watch", models: ["Apple Watch Ultra 2", "Apple Watch Ultra", "Apple Watch Series 10", "Apple Watch Series 9", "Apple Watch Series 8", "Apple Watch SE"])]
        case .gamingLaptop:
            return [TradeInBrandGroup(brand: "Gaming Laptops", models: ["ASUS ROG Zephyrus", "Razer Blade", "Alienware", "Lenovo Legion", "HP Omen", "Acer Predator", "MSI Stealth"])]
        case .monitor:
            return [TradeInBrandGroup(brand: "Monitors", models: ["Apple Studio Display", "Apple Pro Display XDR", "LG UltraFine 5K", "Dell UltraSharp 4K", "Samsung Odyssey"])]
        case .tv:
            return [TradeInBrandGroup(brand: "TVs", models: ["Samsung OLED/QLED TV", "LG OLED TV", "Sony Bravia TV", "TCL Mini-LED TV", "Hisense ULED TV", "Other TV"])]
        case .miscellaneous:
            return [TradeInBrandGroup(brand: "Miscellaneous", models: ["Other electronics", "Camera", "Speaker", "Scooter", "Smart home gear", "Random trade item"])]
        }
    }
}
