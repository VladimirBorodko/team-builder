import Foundation
import Facility
import FacilityAutomates
import FacilityQueries
public struct FileRuleChecker {
  public var resolveAbsolutePath: Try.Reply<ResolveAbsolutePath>
  public var handleFileList: Try.Reply<Git.HandleFileList>
  public var listFileLines: Try.Reply<ListFileLines>
  public init(
    resolveAbsolutePath: @escaping Try.Reply<ResolveAbsolutePath>,
    handleFileList: @escaping Try.Reply<Git.HandleFileList>,
    listFileLines: @escaping Try.Reply<ListFileLines>
  ) {
    self.resolveAbsolutePath = resolveAbsolutePath
    self.handleFileList = handleFileList
    self.listFileLines = listFileLines
  }
  public func run(context: inout Context) throws {
    var reportage = ValidationResult()
    let nameRules = try context.fileRules
      .get()
      .filter { $0.lines.isEmpty }
    let lineRules = try context.fileRules
      .get()
      .filter { !$0.lines.isEmpty }
    let files = try Id
      .make(Git.Ref.head)
      .map(context.git.listTrackedFiles(ref:))
      .map(handleFileList)
      .get()
    for file in files {
      reportage.issues += nameRules
        .filter { $0.files.isMet(file) }
        .map { "\(file): \($0.rule)" }
      let lineRules = lineRules
        .filter { $0.files.isMet(file) }
      reportage.issues += try lineRules
        .isEmpty
        .else(file)
        .map(context.git.root.makeResolve(path:))
        .map(resolveAbsolutePath)
        .map(ListFileLines.init(file:))
        .map(listFileLines)
        .or(.init({nil}))
        .enumerated()
        .flatMap { row, line in lineRules
          .filter { $0.lines.isMet(line) }
          .map { "\(file) @ \(row): \($0.rule)" }
        }
    }
    context.reportages.append(reportage)
  }
}
