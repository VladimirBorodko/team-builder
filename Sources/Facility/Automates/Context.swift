import Foundation
import Facility
public struct Context {
  public var git: Git
  public var env: [String: String]
  public var command: String
  public var fileOwnage: Lossy<[String: Criteria]> = .init()
  public var fileRules: Lossy<[FileRule]> = .init()
  public var notifications: Lossy<Notifications> = .init()
  public var members: Lossy<Members> = .init()
  public var reportages: [Reportage] = []
  public init(
    configuration: Configuration,
    git: Git
  ) {
    self.git = git
    self.env = configuration.env
    self.command = configuration.command
  }
  public func resolveEnvValue(key: String) throws -> String {
    try env[key].or { throw Thrown("No env \(key)") }
  }
  public struct Notifications {
    public var slackHooks: [String: [Lossy<SlackHook>]] = [:]
    public init() {}
    public struct SlackHook {
      public var url: String
      public var channel: String
      public var template: String
      public var emojiIcon: String?
      public var optional: Bool
      public init(
        url: String,
        channel: String,
        template: String,
        emojiIcon: String?,
        optional: Bool
      ) {
        self.url = url
        self.channel = channel
        self.template = template
        self.emojiIcon = emojiIcon
        self.optional = optional
      }
      public func makePayload(text: String) -> Payload {.init(
        username: "TeamBuilder",
        channel: "#\(channel)",
        text: text,
        iconEmoji: emojiIcon.map { ":\($0):" }
      )}
      public struct Payload: Encodable {
        var username: String
        var channel: String
        var text: String
        var iconEmoji: String?
      }
    }
  }
  public struct Members {
    public var names: [String: String] = [:]
    public var emails: [String: String] = [:]
    public var slackMentions: [String: String] = [:]
    public var bots: Set<String> = []
    public var maintainers: Set<String> = []
    public var developers: Set<String> = []
    public init(yaml: [String: Yaml.Member]) {
      for (login, member) in yaml {
        switch member.kind {
        case .bot: bots.insert(login)
        case .developer: bots.insert(login)
        case .maintainer: bots.insert(login)
        }
        names[login] = member.name
        emails[login] = member.email
        slackMentions[login] = member.slack
      }
    }
  }
  public struct FileRule {
    public var rule: String
    public var files: Criteria
    public var lines: Criteria
    public init(yaml: Yaml.FileRule) throws {
      self.rule = yaml.rule
      self.files = try .init(includes: yaml.file?.include, excludes: yaml.file?.exclude)
      self.lines = try .init(includes: yaml.line?.include, excludes: yaml.line?.exclude)
      if files.isEmpty && lines.isEmpty {
        throw Thrown("Empty rule \(yaml.rule)")
      }
    }
  }
}
//public struct Configuration {
//  public var git: Git
//  public var fileOwnage: Git.File?
//  public var fileRules: Git.File?
//  public var members: Git.File?
//  public var approvers: Git.File?
//  public var approvals: Git.File?
//  public var notifications: Git.File?
//  public var vacations: Git.File?
//  public var versions: Git.File?
//  public var builds: Git.File?
//  public var deployKey: Dependency?
//  public var accessToken: Dependency?
//  public var triggerToken: Dependency?
//  public var slackHook: Dependency?
//  public var keychain: String?
//  public var provisions: [Git.Tree]
//  public var developmentCodesign: Git.File?
//  public var developmentPassword: Dependency?
//  public var distributionCodesign: Git.File?
//  public var distributionPassword: Dependency?
//  public enum Dependency {
//    case value(String)
//    case envVar(String)
//    case envFile(String)
//    static func make(yaml: Yaml.Dependency) -> Self? {
//      yaml.value.map(Self.value)
//        .flatMapNil(yaml.envVar.map(Self.envVar))
//        .flatMapNil(yaml.envFile.map(Self.envFile))
//    }
//  }
//}
//extension Git {
//  public func makeProfile(settings: Yaml.Profile) throws -> Configuration {
//    try .init(
//      git: self,
//      fileOwnage: settings.fileOwnage
//        .map(makeFile(yaml:)),
//      fileRules: settings.fileRules
//        .map(makeFile(yaml:)),
//      members: settings.members
//        .map(makeFile(yaml:)),
//      approvers: settings.approvers
//        .map(makeFile(yaml:)),
//      approvals: settings.approvals
//        .map(makeFile(yaml:)),
//      notifications: settings.notifications
//        .map(makeFile(yaml:)),
//      vacations: settings.vacations
//        .map(makeFile(yaml:)),
//      versions: settings.versions
//        .map(makeFile(yaml:)),
//      builds: settings.builds
//        .map(makeFile(yaml:)),
//      deployKey: settings.deployKey
//        .flatMap(Configuration.Dependency.make(yaml:)),
//      accessToken: settings.accessToken
//        .flatMap(Configuration.Dependency.make(yaml:)),
//      triggerToken: settings.triggerToken
//        .flatMap(Configuration.Dependency.make(yaml:)),
//      slackHook: settings.slackHook
//        .flatMap(Configuration.Dependency.make(yaml:)),
//      keychain: settings.requisite?.keychain,
//      provisions: settings.requisite
//        .map(\.provisions)
//        .or([])
//        .map(makeTree(yaml:)),
//      developmentCodesign: settings.requisite
//        .map(\.developmentCodesign)
//        .map(makeFile(yaml:)),
//      developmentPassword: settings.requisite
//        .map(\.developmentPassword)
//        .flatMap(Configuration.Dependency.make(yaml:)),
//      distributionCodesign: settings.requisite
//        .map(\.distributionCodesign)
//        .map(makeFile(yaml:)),
//      distributionPassword: settings.requisite
//        .map(\.distributionPassword)
//        .flatMap(Configuration.Dependency.make(yaml:))
//    )
//  }
//}
