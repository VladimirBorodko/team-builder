import Foundation
import Facility
import FacilityQueries
import FacilityAutomates
public struct Configurator {
  public var decodeYaml: Try.Reply<DecodeYaml>
  public var resolveAbsolutePath: Try.Reply<ResolveAbsolutePath>
  public var readFile: Try.Reply<ReadFile>
  public var gitHandleLine: Try.Reply<Git.HandleLine>
  public var gitHandleCat: Try.Reply<Git.HandleCat>
  public var gitHandleVoid: Try.Reply<Git.HandleVoid>
  public var getEnvironment: Act.Reply<GetEnvironment>
  public init(
    decodeYaml: @escaping Try.Reply<DecodeYaml>,
    resolveAbsolutePath: @escaping Try.Reply<ResolveAbsolutePath>,
    readFile: @escaping Try.Reply<ReadFile>,
    gitHandleLine: @escaping Try.Reply<Git.HandleLine>,
    gitHandleCat: @escaping Try.Reply<Git.HandleCat>,
    gitHandleVoid: @escaping Try.Reply<Git.HandleVoid>,
    getEnvironment: @escaping Act.Reply<GetEnvironment>
  ) {
    self.decodeYaml = decodeYaml
    self.resolveAbsolutePath = resolveAbsolutePath
    self.readFile = readFile
    self.gitHandleLine = gitHandleLine
    self.gitHandleCat = gitHandleCat
    self.gitHandleVoid = gitHandleVoid
    self.getEnvironment = getEnvironment
  }
  public func makeContext(configuration: Configuration) throws -> Context {
    var context = try Id
      .make(configuration.project)
      .map(resolve(project:))
      .reduce(configuration, Git.init(configuration:root:))
      .reduce(configuration, Context.init(configuration:git:))
      .get()
    try setupRepo(context: &context)
    let profile = parseProfile(configuration: configuration, git: context.git)
    parseFileRules(context: &context, profile: profile)
    parseFileOwnage(context: &context, profile: profile)
    parseNotifications(context: &context, profile: profile)
    parseMembers(context: &context, profile: profile)
    return context
  }
}
private extension Configurator {
  func resolve(project: String) throws -> Path.Absolute { try Id
    .make(project)
    .map(ResolveAbsolutePath.make(path:))
    .map(resolveAbsolutePath)
    .map(Git.HandleLine.make(resolveTopLevel:))
    .map(gitHandleLine)
    .map(Path.Absolute.init(path:))
    .get()
  }
  func parseProfile(configuration: Configuration, git: Git) -> Lossy<Yaml.Profile> { Lossy
    .init(try .init(name: configuration.branch, remote: git.remoteName))
    .map(Git.Ref.make(branch:))
    .reduce(try .init(path: configuration.profile), Git.File.init(path:ref:))
    .map(git.cat(file:))
    .map(gitHandleCat)
    .map(String.make(utf8:))
    .map(DecodeYaml.init(content:))
    .map(decodeYaml)
    .reduce(Yaml.Profile.self, AnyCodable.Dialect.json.read(_:from:))
  }
  func parseFileOwnage(
    context: inout Context,
    profile: Lossy<Yaml.Profile>
  ) { context.fileOwnage = profile
    .map(\.satellites?.fileOwnage)
    .reduce(curry: Thrown("No fileOwnage in profile"), Optional.or(error:))
    .map(Path.Relative.init(path:))
    .reduce(invert: context.git.ref, Git.File.init(path:ref:))
    .reduce(context.git, parse(git:file:))
    .reduce([String: Yaml.Criteria].self, AnyCodable.Dialect.json.read(_:from:))
    .reduce(curry: Criteria.init(yaml:), Dictionary.mapValues(_:))
  }
  func parseFileRules(
    context: inout Context,
    profile: Lossy<Yaml.Profile>
  ) { context.fileRules = profile
    .map(\.satellites?.fileRules)
    .reduce(curry: Thrown("No fileRules in profile"), Optional.or(error:))
    .map(Path.Relative.init(path:))
    .reduce(invert: context.git.ref, Git.File.init(path:ref:))
    .reduce(context.git, parse(git:file:))
    .reduce([Yaml.FileRule].self, AnyCodable.Dialect.json.read(_:from:))
    .reduce(curry: Context.FileRule.init(yaml:), Array.map(_:))
  }
  func parseNotifications(
    context: inout Context,
    profile: Lossy<Yaml.Profile>
  ) { context.notifications = profile
      .map(\.controls?.notifications)
      .reduce(curry: Thrown("No notifications in profile"), Optional.or(error:))
      .map(Path.Relative.init(path:))
      .reduce(invert: context.git.controlsRef, Git.File.init(path:ref:))
      .reduce(context.git, parse(git:file:))
      .reduce(Yaml.Notifications.self, AnyCodable.Dialect.json.read(_:from:))
      .reduce(context, makeNotifications(context:notifications:))
  }
  func parseMembers(
    context: inout Context,
    profile: Lossy<Yaml.Profile>
  ) { context.members = profile
    .map(\.controls?.members)
    .reduce(curry: Thrown("No notifications in profile"), Optional.or(error:))
    .map(Path.Relative.init(path:))
    .reduce(invert: context.git.controlsRef, Git.File.init(path:ref:))
    .reduce(context.git, parse(git:file:))
    .reduce([String: Yaml.Member].self, AnyCodable.Dialect.json.read(_:from:))
    .map(Context.Members.init(yaml:))
  }
  func setupRepo(context: inout Context) throws {
    if context.git.lfs { try gitHandleVoid(context.git.updateLfs) }
    try (context.env["GITLAB_CI"] != nil)
      .then(makeFetchUrl(git: context.git, env: context.env))
      .map(context.git.addRemote(url:))
      .map(gitHandleVoid)
    try gitHandleVoid(context.git.fetch)
    context.git.report.userName = try? gitHandleLine(context.git.userName)
    context.git.report.headSha = try? gitHandleLine(context.git.headSha)
  }
  func makeNotifications(
    context: Context,
    notifications: Yaml.Notifications
  ) -> Context.Notifications {
    let slackHooks = notifications.slackHooks.or([:]).mapValues { hook in Lossy
      .value(hook)
      .reduce(context, resolve(context:dependency:))
      .reduce(curry: Thrown("No value or envVar or envFile in \(hook)"), Optional.or(error:))
    }
    var result = Context.Notifications()
    for message in notifications.slackHookMessages.or([]) {
      let hook = slackHooks[message.hook]
        .or(.error(Thrown("No \(message.hook) in slackHooks")))
      let template = Lossy
        .value(message.templateFile)
        .map(Path.Relative.init(path:))
        .reduce(invert: context.git.controlsRef, Git.File.init(path:ref:))
        .map(context.git.cat(file:))
        .map(gitHandleCat)
        .map(String.make(utf8:))
      let notification = [Lossy(try Context.Notifications.SlackHook(
        url: hook.get(),
        channel: message.channel,
        template: template.get(),
        emojiIcon: message.emojiIcon,
        optional: message.optional ?? false
      ))]
      for trigger in message.triggers {
        result.slackHooks[trigger] = result.slackHooks[trigger].or([]) + notification
      }
    }
    return result
  }
  func makeFetchUrl(git: Git, env: [String: String]) throws -> String { try Lossy
    .init(try [
      "\(?!env["CI_SERVER_PROTOCOL"])://",
      "gitlab-ci-token:\(?!env["CI_JOB_TOKEN"])@",
      "\(?!env["CI_SERVER_HOST"])",
      ":\(?!env["CI_SERVER_PORT"])",
      "/\(?!env["CI_PROJECT_PATH"])",
    ])
    .rethrow(Thrown("Fetch url compilation failed"))
    .reduce(curry: "", Array.joined(separator:))
    .get()
  }
  func parse(git: Git, file: Git.File) throws -> AnyCodable { try Id
    .make(file)
    .map(git.cat(file:))
    .map(gitHandleCat)
    .map(String.make(utf8:))
    .map(DecodeYaml.init(content:))
    .map(decodeYaml)
    .get()
  }
  func resolve(
    context: Context,
    dependency: Yaml.Dependency
  ) throws -> String? { try dependency.value
    .flatMapNil { try dependency.envVar.map(context.resolveEnvValue(key:)) }
    .flatMapNil { try dependency.envFile
      .map(context.resolveEnvValue(key:))
      .map(Path.Absolute.init(path:))
      .map(ReadFile.init(file:))
      .map(readFile)
      .map(String.make(utf8:))
    }
  }
}
