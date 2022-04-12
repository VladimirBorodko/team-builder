import Foundation
import Facility
public struct RenderStencil: Query {
  public var template: String
  public var context: [[String: Any]]
  public init(template: String, context: [[String: Any]]) {
    self.template = template
    self.context = context
  }
  public typealias Reply = String
}
