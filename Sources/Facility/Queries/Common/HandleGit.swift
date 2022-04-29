import Foundation
import Facility
import FacilityAutomates
public extension Git {
  func listChangedFiles(ref: Git.Ref) -> HandleFileList {
    .init(tasks: [
      .init(arguments: root.base + ["diff", "--name-only", "--merge-base", ref.value]),
    ])
  }
  func listTrackedFiles(ref: Git.Ref) -> HandleFileList {
    .init(tasks: [
      .init(arguments: root.base + ["ls-tree", "-r", "--name-only", "--full-tree", ref.value, "."]),
    ])
  }
  var updateLfs: Git.HandleVoid {
    .init(tasks: [.init(arguments: root.base + ["lfs", "update"])])
  }
  var fetch: Git.HandleVoid {
    .init(tasks: [.init(arguments: root.base + ["fetch", remoteName])])
  }
  func addRemote(url: String) -> Git.HandleVoid {
    .init(tasks: [.init(arguments: root.base + ["remote", "add", remoteName, url])])
  }
  func cat(file: Git.File) throws -> Git.HandleCat {
    .init(tasks: [
      .init(arguments: root.base + ["show", "\(file.ref.value):\(file.path.path)"]),
      .init(surpassStdErr: true, arguments: root.base + ["lfs", "smudge"]),
    ])
  }
  var userName: HandleLine {
    .init(tasks: [.init(arguments: root.base + ["config", "user.name"])])
  }
  var headSha: HandleLine {
    .init(tasks: [.init(arguments: root.base + ["rev-parse", "HEAD"])])
  }
  struct HandleFileList: ProcessHandler {
    public var tasks: [PipeTask]
    public func handle(data: Data) throws -> Reply { try Id
      .make(data)
      .map(String.make(utf8:))
      .reduce(tryCurry: .newlines, String.components(separatedBy:))
      .map(String.makeFileNames(lines:))
      .map(AnyIterator.init(_:))
      .get()
    }
    public typealias Reply = AnyIterator<String>
  }
  struct HandleLine: ProcessHandler {
    public var tasks: [PipeTask]
    public func handle(data: Data) throws -> Reply { try Id
      .make(data)
      .map(String.make(utf8:))
      .reduce(curry: .newlines, String.trimmingCharacters(in:))
      .get()
    }
    public static func make(resolveTopLevel path: Path.Absolute) -> Self {
      .init(tasks: [.init(arguments: path.base + ["rev-parse", "--show-toplevel"])])
    }
    public typealias Reply = String
  }
  struct HandleVoid: ProcessHandler {
    public var tasks: [PipeTask]
    public func handle(data: Data) throws -> Reply {}
    public typealias Reply = Void
  }
  struct HandleCat: ProcessHandler {
    public var tasks: [PipeTask]
    public func handle(data: Data) throws -> Reply { data }
    public typealias Reply = Data
  }
}
private extension Path.Absolute {
  var base: [String] { ["git", "-C", path] }
}
private extension String {
  static func makeFileNames(lines: [String]) -> Array<String>.Iterator { lines
    .map { $0.trimmingCharacters(in: .init(charactersIn: "\"")) }
    .filter { !$0.isEmpty }
    .lazy
    .makeIterator()
  }
  static func makeLine(data: Data) throws -> String { try String
    .make(utf8: data)
    .trimmingCharacters(in: .newlines)
  }
}
