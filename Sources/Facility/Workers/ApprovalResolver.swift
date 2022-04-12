import Foundation
import Facility
import FacilityAutomates
import FacilityQueries
//public struct ApprovalKit {
//  public var reportOwnage: Try.Reply<ReportOwnage>
//  public var parseGitFile: Try.Reply<ParseGitFile>
//  public var processGitFileList: Try.Reply<Git.HandleFileList>
//  public var readEnvironment: Try.Reply<ReadEnvironment>
//  public init(
//    reportOwnage: @escaping Try.Reply<ReportOwnage>,
//    parseGitFile: @escaping Try.Reply<ParseGitFile>,
//    processGitFileList: @escaping Try.Reply<Git.HandleFileList>,
//    readEnvironment: @escaping Try.Reply<ReadEnvironment>
//  ) {
//    self.reportOwnage = reportOwnage
//    self.parseGitFile = parseGitFile
//    self.processGitFileList = processGitFileList
//    self.readEnvironment = readEnvironment
//  }
//}
//public extension ApprovalKit {
//  func run(config: Profile) throws {
//    let approvals = try config.approvals
//      .map(config.git.makeParseGitFile(file:))
//      .map(parseGitFile)
//      .map(Interpreter.makeDefault(tree:))
//      .map(Yaml.Approvals.init(from:))
//      .reduce(into: .init(), Approvals.append(approvals:yaml:))
//    let targetBranch =  try Id
//      .make("CI_MERGE_REQUEST_TARGET_BRANCH_NAME")
//      .map(ReadEnvironment.init(name:))
//      .map(readEnvironment)
//      .map(Optional.unwrap(value:))
//      .unwrap()
//    let sourceBranch = try Id
//      .make("CI_MERGE_REQUEST_SOURCE_BRANCH_NAME")
//      .map(ReadEnvironment.init(name:))
//      .map(readEnvironment)
//      .map(Optional.unwrap(value:))
//      .unwrap()
//    let files = try Id
//      .make(targetBranch)
//      .invertReduce(config.git.remoteName, Git.Branch.init(name:remote:))
//      .map(Git.Ref.make(branch:))
//      .map(config.git.listChangedFiles(ref:))
//      .map(processGitFileList)
//      .unwrap()
//    let author: String = ""
//    var reported: Set<String> = []
//    for file in files {
//      for fileChange in approvals.fileCriteria {
//        guard !reported.contains(fileChange.approval) else { continue }
//        guard fileChange.criteria.isMet(file) else { continue }
//        _ = reported.insert(fileChange.approval)
//      }
//    }
//    for branch in approvals.targetBranchCriteria {
//      guard !reported.contains(branch.approval) else { continue }
//      guard branch.criteria.isMet(targetBranch) else { continue }
//      _ = reported.insert(branch.approval)
//    }
//    for branch in approvals.sourceBranchCriteria {
//      guard !reported.contains(branch.approval) else { continue }
//      guard branch.criteria.isMet(sourceBranch) else { continue }
//      _ = reported.insert(branch.approval)
//    }
//    for user in approvals.teamReview {
//      guard !reported.contains(user.approval) else { continue }
//      guard user.names.contains(author) else { continue }
//      _ = reported.insert(user.approval)
//    }
//    try reported
//      .map(ReportOwnage.init(owner:))
//      .forEach(reportOwnage)
//  }
//}
