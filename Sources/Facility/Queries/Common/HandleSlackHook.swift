import Foundation
import Facility
import FacilityAutomates
public struct HandleSlackHook: ProcessHandler {
  public var tasks: [PipeTask]
  public init(url: String, payload: String) throws {
    self.tasks = [.makeCurl(
      url: url,
      method: "POST",
      retry: 2,
      urlencode: ["payload=\(payload)"]
    )]
  }
  public func handle(data: Data) throws -> Reply { try Id
    .make(data)
    .map(String.make(utf8:))
    .get()
  }
  public typealias Reply = String
}
