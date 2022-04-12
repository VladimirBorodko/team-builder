import Foundation
public struct Configuration {
  public var env: [String: String]
  public var command: String
  public var project: String
  public var remote: String
  public var noLfs: Bool
  public var profile: String
  public var branch: String
  public var pipeline: String
  public init(
    env: [String : String],
    command: String,
    project: String,
    remote: String,
    noLfs: Bool,
    profile: String,
    branch: String,
    pipeline: String
  ) {
    self.env = env
    self.command = command
    self.project = project
    self.remote = remote
    self.noLfs = noLfs
    self.profile = profile
    self.branch = branch
    self.pipeline = pipeline
  }
}
