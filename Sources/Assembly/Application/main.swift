import Foundation
import Foundation
import Facility
import FacilityAutomates
import FacilityQueries
import FacilityWorkers
import InteractivityCommon
import InteractivityYams
import InteractivityStencil
import InteractivityPathKit
enum Main {
  static let configurator = Configurator(
    decodeYaml: YamlParser.decodeYaml(query:),
    resolveAbsolutePath: Finder.resolveAbsolutePath(query:),
    readFile: Finder.readFile(query:),
    gitHandleLine: Processor.handleProcess(query:),
    gitHandleCat: Processor.handleProcess(query:),
    gitHandleVoid: Processor.handleProcess(query:),
    getEnvironment: Processor.getEnvironment(query:)
  )
  static let reporter = Reporter(
    logLine: FileHandle.standardError.write(message:),
    getTime: Date.init,
    renderStencil: StencilParser.renderStencil(query:),
    handleSlackHook: Processor.handleProcess(query:)
  )
  static let environment = ProcessInfo.processInfo.environment
  static let unownedCodeChecker = UnownedCodeChecker(
    processGitFileList: Processor.handleProcess(query:)
  )
  static let fileRuleChecker = FileRuleChecker(
    resolveAbsolutePath: Finder.resolveAbsolutePath(query:),
    handleFileList: Processor.handleProcess(query:),
    listFileLines: FileLiner.listFileLines(query:)
  )
}
MayDay.sideEffect = { mayDay in FileHandle.standardError.write(
  message: """
    ⚠️⚠️⚠️
    Please submit an issue at https://github.com/VladimirBorodko/team-builder/issues/new/choose
    Version: \(TeamBuilder.version)
    What: \(mayDay.what)
    File: \(mayDay.file)
    Line: \(mayDay.line)
    ⚠️⚠️⚠️
    """
)}
TeamBuilder.main()
