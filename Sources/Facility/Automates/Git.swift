import Foundation
import Facility
public struct Git {
  public var root: Path.Absolute
  public var remoteName: String
  public var lfs: Bool
  public var ref: Ref = .head
  public var controlsRef: Ref
  public var report: Report = .init()
  public init(
    configuration: Configuration,
    root: Path.Absolute
  ) throws {
    self.root = root
    self.remoteName = configuration.remote
    self.lfs = !configuration.noLfs
    self.controlsRef = try Id
      .make(configuration.branch)
      .reduce(invert: remoteName, Branch.init(name:remote:))
      .map(Ref.make(branch:))
      .get()
  }
  public struct File {
    public var path: Path.Relative
    public var ref: Ref
    public init(path: Path.Relative, ref: Ref) {
      self.path = path
      self.ref = ref
    }
    public init(local: String) throws {
      self.path = try .init(path: local)
      self.ref = .head
    }
  }
  public struct Tree {
    public var path: Path.Relative
    public var ref: Ref
    public init(path: Path.Relative, ref: Ref) {
      self.path = path
      self.ref = ref
    }
  }
  public struct Ref {
    public let value: String
    public static var head: Self { .init(value: "HEAD") }
    public static func make(sha: Sha) throws -> Self {
      return .init(value: sha.ref)
    }
    public static func make(tag: String) throws -> Self {
      guard !tag.isEmpty else { throw Thrown("tag is empty") }
      return .init(value: "refs/tags/\(tag)")
    }
    public static func make(branch: Branch) throws -> Self {
      return .init(value: branch.ref)
    }
  }
  public struct Sha {
    public let ref: String
    public init(ref: String) throws {
      guard ref.count == 40, ref.trimmingCharacters(in: .hexadecimalDigits).isEmpty else {
        throw Thrown("not sha: \(ref)")
      }
      self.ref = ref
    }
  }
  public struct Branch {
    public let ref: String
    public init(name: String, remote: String? = nil) throws {
      if name.isEmpty { throw Thrown("branch is empty") }
      if let remote = remote {
        if remote.isEmpty { throw Thrown("remote is empty") }
        if remote.contains("/") { throw Thrown("remote contains /") }
        self.ref = "refs/remotes/\(remote)/\(name)"
      } else {
        self.ref = "refs/heads/\(name)"
      }
    }
  }
  public struct Report: Encodable {
    public var userName: String? = nil
    public var headSha: String? = nil
  }
}
