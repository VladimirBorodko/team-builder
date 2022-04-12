import Foundation
import Facility
import FacilityAutomates
import FacilityQueries
public struct UnownedCodeChecker {
  public var processGitFileList: Try.Reply<Git.HandleFileList>
  public init(
    processGitFileList: @escaping Try.Reply<Git.HandleFileList>
  ) {
    self.processGitFileList = processGitFileList
  }
  public func run(context: inout Context) throws {
    var reportage = ValidationResult()
    let approvals = try context.fileOwnage.get()
    reportage.issues += try Id
      .make(context.git)
      .reduce(curry: .head, Git.listTrackedFiles(ref:))
      .map(processGitFileList)
      .get()
      .filter { file in !approvals.contains { $0.value.isMet(file) } }
      .map { "Unowned: \($0)" }
    context.reportages.append(reportage)
  }
}
