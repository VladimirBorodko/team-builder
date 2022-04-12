import Foundation
import Facility
public enum Yaml {
  public struct Profile: Decodable {
    public var satellites: Satellites?
    public var controls: Controls?
    public var requisites: Requisites?
    public var deployKey: Dependency?
    public var accessToken: Dependency?
    public var triggerToken: Dependency?
  }
  public struct Satellites: Decodable {
    public var tools: String?
    public var sanity: String?
    public var fileRules: String?
    public var fileOwnage: String?
  }
  public struct Controls: Decodable {
    public var members: String?
    public var approvers: String?
    public var approvals: String?
    public var notifications: String?
    public var taboos: String?
  }
  public struct Requisites: Decodable {
    public var branch: String
    public var builds: String?
    public var versions: String?
    public var vacations: String?
    public var keychain: String?
    public var provisions: String?
    public var developmentCodesign: Codesign?
    public var distributionCodesign: Codesign?
  }
  public struct Codesign: Decodable {
    public var crypto: String
    public var password: Dependency
  }
  public struct Dependency: Decodable {
    public var value: String?
    public var envVar: String?
    public var envFile: String?
  }
  public struct Approvals: Decodable {
    public var branchApproval: [String: Criteria]?
    public var personalApproval: [String: [String]]?
  }
  public struct Member: Decodable {
    public var kind: Kind
    public var name: String?
    public var email: String?
    public var slack: String?
    public enum Kind: String, Decodable {
      case bot
      case developer
      case maintainer
    }
  }
  public struct Approvers: Decodable {
    public var hold: Group?
    public var sanity: Group?
    public var reserve: Group?
    public var emergency: Group?
    public var groups: [String: Group]?
    public struct Group: Decodable {
      public var award: String
      public var quote: Int
      public var slackAward: String?
      public var slackWatchers: String?
      public var required: [String]?
      public var collective: [String]?
    }
  }
  public struct Notifications: Decodable {
    public var slackHooks: [String: Dependency]?
    public var slackHookMessages: [SlackHookMessage]?
    public var custom: AnyCodable?
  }
  public struct SlackHookMessage: Decodable {
    public var hook: String
    public var channel: String
    public var templateFile: String
    public var emojiIcon: String?
    public var optional: Bool?
    public var triggers: [String]
  }
  public struct Sanity: Decodable {
    public var obsolete: [Criteria]?
  }
  public struct Taboos: Decodable {
    public var reviewTarget: [Criteria]?
    public var reviewSource: [Criteria]?
    public var reviewTitle: [Criteria]?
  }
  public struct FileRule: Decodable {
    public var rule: String
    public var file: Criteria?
    public var line: Criteria?
  }
  public struct Criteria: Decodable {
    var include: [String]?
    var exclude: [String]?
  }
}
