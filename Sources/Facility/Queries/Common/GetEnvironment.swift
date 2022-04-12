import Foundation
import Facility
public struct GetEnvironment: Query {
  public init() {}
  public typealias Reply = [String: String]
}
