import Foundation
import Facility
import FacilityQueries
import FacilityAutomates
public struct Reporter {
  public var logLine: Act.Of<String>.Go
  public var getTime: Act.Do<Date>
  public var renderStencil: Try.Reply<RenderStencil>
  public var handleSlackHook: Try.Reply<HandleSlackHook>
  public var formatter: DateFormatter
  public private(set) var issueCount: UInt = 0
  public init(
    logLine: @escaping Act.Of<String>.Go,
    getTime: @escaping Act.Do<Date>,
    renderStencil: @escaping Try.Reply<RenderStencil>,
    handleSlackHook: @escaping Try.Reply<HandleSlackHook>
  ) {
    self.logLine = logLine
    self.getTime = getTime
    self.renderStencil = renderStencil
    self.handleSlackHook = handleSlackHook
    self.formatter = .init()
    formatter.dateFormat = "HH:mm:ss"
  }
  public func report(context: Context) throws {
    var fatal = false
    let notifications = try context.notifications.get()
    let parcel: [String: Any] = [
      "command": context.command,
      "env": context.env,
      "git": context.git.report,
    ]
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    for reportage in context.reportages {
      fatal = fatal || reportage.fatal
      reportage.log.forEach(log(message:))
      for slackHook in notifications.slackHooks[reportage.kind].or([]) {
        var currentFatal = true
        do {
          let slackHook = try slackHook.get()
          currentFatal = !slackHook.optional
          let text = try ?!Id([parcel, reportage.report])
            .reduce(slackHook.template, RenderStencil.init(template:context:))
            .map(renderStencil)
            .reduce(curry: .newlines, String.trimmingCharacters(in:))
          guard !text.isEmpty else { throw Thrown("rendered text is empty") }
          _ = try ?!Id(slackHook)
            .reduce(tryCurry: text, Context.Notifications.SlackHook.makePayload(text:))
            .map(encoder.encode(_:))
            .map(String.make(utf8:))
            .reduce(slackHook.url, HandleSlackHook.init(url:payload:))
            .map(handleSlackHook)
        } catch {
          log(message: "Message delivery failed: \(error)")
          fatal = fatal || currentFatal
        }
      }
    }
    if fatal { throw Thrown("See log for details") }
  }
  private func log(message: String) { message
    .split(separator: "\n")
    .compactMap { line in line.isEmpty.else("[\(formatter.string(from: getTime()))]: \(line)") }
    .forEach(logLine)
  }
}
