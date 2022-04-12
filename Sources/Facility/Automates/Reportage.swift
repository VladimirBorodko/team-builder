import Foundation
public protocol Reportage {
  var kind: String { get }
  var fatal: Bool { get }
  var log: [String] { get }
  var report: [String: Encodable] { get }
}
public struct ValidationResult: Reportage {
  public var issues: [String] = []
  public init() {}
  public var kind: String { issues.isEmpty.then("ValidationSuccess").or("ValidationIssues") }
  public var fatal: Bool { !issues.isEmpty }
  public var log: [String] { issues }
  public var report: [String: Encodable] { ["issues": issues] }
}
public struct Failure: Reportage {
  public var error: Error
  public init(error: Error) { self.error = error }
  public var kind: String { "Failure" }
  public var fatal: Bool { true }
  public var log: [String] { ["\(error)"] }
  public var report: [String: Encodable] { ["error": "\(error)"] }
}
