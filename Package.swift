// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
import Foundation
let package = Package(
  name: "TeamBuilder",
  products: [.executable(name: "team-builder", targets: ["TeamBuilder"])],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.1"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.2"),
    .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
    .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.14.1"),
    .package(url: "https://github.com/VladimirBorodko/Utility", from: "0.5.0"),
  ],
  targets: [
    .executableTarget(
      name: "TeamBuilder",
      dependencies: .assembly + [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      path: "Sources/Assembly"
    ),
    .interactivity("PathKit", extra: [
      "PathKit",
      "InteractivityCommon",
    ]),
    .interactivity("Yams", extra: [
      "Yams",
    ]),
    .interactivity("Stencil", extra: [
      "Stencil",
    ]),
    .interactivity("Common"),
    .facility("Workers", extra: ["FacilityAutomates", "FacilityQueries"]),
    .facility("Queries", extra: ["FacilityAutomates"]),
    .facility("Automates"),
  ]
)
extension Target {
  static func interactivity(_ name: String, extra dependencies: [Dependency] = []) -> Target {
    utility("Interactivity", name, dependencies + .interactivity + .facilities + .facility)
  }
  static func facility(_ name: String, extra dependencies: [Dependency] = []) -> Target {
    utility("Facility", name, dependencies + .facility)
  }
  private static func utility(
    _ layer: String,
    _ name: String,
    _ dependencies: [Dependency]
  ) -> Target {
    self.target(
      name: "\(layer)\(name)",
      dependencies: dependencies,
      path: "Sources/\(layer)/\(name)"
    )
  }
}
extension Array where Element == Target.Dependency {
  static let assembly: Self = facility + facilities + interactivity + interactivities
  static let interactivities: Self = [
    "InteractivityCommon",
    "InteractivityPathKit",
    "InteractivityStencil",
    "InteractivityYams",
  ]
  static let interactivity: Self = [
    .product(name: "Interactivity", package: "Utility"),
  ]
  static let facilities: Self = [
    "FacilityWorkers",
    "FacilityAutomates",
    "FacilityQueries",
  ]
  static let facility: Self = [
    .product(name: "Facility", package: "Utility")
  ]
}
