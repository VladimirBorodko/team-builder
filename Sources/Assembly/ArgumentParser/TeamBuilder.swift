import ArgumentParser
import Foundation
import Facility
import FacilityAutomates
struct TeamBuilder: ParsableCommand {
  @Option(help: "The path to the repo directory")
  var project = ""
  @Option(help: "The path to the profile")
  var profile = "TeamBuilder/Profile.yml"
  @Option(help: "Name of the remote to work with")
  var remote = "origin"
  @Option(help: "Name of the branch with profile")
  var branch = "share/controls"
  @Flag
  var noLfs = false
  static let configuration = CommandConfiguration(
    abstract: "Distributed scalable monorepo management tool",
    version: version,
    subcommands: [
      CheckUnownedCode.self,
      CheckFileRules.self,
    ]
  )
  static let version = "0.0.1"
  struct CheckUnownedCode: TeamBuilderCommand {
    @OptionGroup var arguments: TeamBuilder
    static var name: String { "check-unowned-code" }
    static var abstract: String { "Ensure no unowned files" }
    func run(context: inout Context) throws {
      try Main.unownedCodeChecker.run(context: &context)
    }
  }
  struct CheckFileRules: TeamBuilderCommand {
    @OptionGroup var arguments: TeamBuilder
    static var name: String { "check-file-rules" }
    static var abstract: String { "Check file rules" }
    func run(context: inout Context) throws {
      try Main.fileRuleChecker.run(context: &context)
    }
  }
}
protocol TeamBuilderCommand: ParsableCommand {
  var arguments: TeamBuilder { get }
  var pipeline: String { get }
  static var name: String { get }
  static var abstract: String { get }
  func run(context: inout Context) throws
}
extension TeamBuilderCommand {
  static var configuration: CommandConfiguration {
    .init(commandName: name, abstract: abstract)
  }
  var pipeline: String { "" }
  mutating func run() throws {
    var context = try Main.configurator.makeContext(configuration: .init(
      env: Main.environment,
      command: Self.name,
      project: arguments.project,
      remote: arguments.remote,
      noLfs: arguments.noLfs,
      profile: arguments.profile,
      branch: arguments.branch,
      pipeline: pipeline
    ))
    do { try run(context: &context) } catch { context.reportages += [Failure(error: error)] }
    try Main.reporter.report(context: context)
  }
}
